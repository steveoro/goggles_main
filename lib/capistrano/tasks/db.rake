# frozen_string_literal: true

namespace :db do
  # Common console header for these tasks
  def display_common_header
    puts "- App service..: #{fetch(:app_service)}"
    puts "- Rails env....: #{fetch(:rails_env)}"
    puts "- Stage........: #{fetch(:stage)}"
  end

  # Simple console display of an array of strings.
  #
  # == Params
  # - lines: the array of strings that has to be shown
  #
  def display_captured_output(lines)
    puts '---------8<----------'
    lines.each { |msg| puts msg }
    puts '---------8<----------'
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
    Runs remotely the 'db:dump' task for the specified deploy stage.

    The 'db:dump' rake task creates inside the 'db/dump' folder a compressed DB dump file
    conveniently named after the running Rails environment. These dumps can be
    easily restored with the counterpart 'db:rebuild' task.

    On the remote host, the 'db/dump' folder is usually mapped onto the '/backups' directory.

    If an additional action parameter is set, a DB dump file can either be
    downloaded (with '[get]', into localhost's 'db/dump') or uploaded (with '[put]',
    into remote host's 'backups').

    A dump file name override can also be set together with the action (see below).


    ** Actions: **

    - nil     => (default) just run 'db:dump' on the remote host.

    - '[get]' => no remote task is run: just *download* the existing remote file into localhost's
                 'db/dump'; any pre-existing local file will be overwritten.

    - '[put]' => no remote task is run: simply *upload* the existing *local* DB dump file
                 found at 'db/dump' to remote host's '/backups' folder; any pre-existing
                 remote file with the same name will be overwritten.


    ** Usage: **

      > cap <STAGE> db:dump

      Run the remote task, creating 'backups/<STAGE>.sql.bz2'

    Or:
      > cap <STAGE> db:dump[get]
      > cap <STAGE> db:dump[get=<FILENAME_OVERRIDE>]

      Download the remote dump file into 'db/dump/<STAGE>.sql.bz2' or
      'db/dump/<FILENAME_OVERRIDE>' if the <FILENAME_OVERRIDE> is set

    Or:
      > cap <STAGE> db:dump[put]
      > cap <STAGE> db:dump[put=<FILENAME_OVERRIDE>]

      Upload the local dump file as 'backups/<STAGE>.sql.bz2' or
      'backups/<FILENAME_OVERRIDE>' if the <FILENAME_OVERRIDE> is set

  DESC
  task :dump, :action do |_t, args|
    display_common_header
    action, name_override = args[:action].to_s.split('=')
    puts "- Action.......: #{action.to_s.empty? ? 'RUN' : action.upcase}"
    file_name = name_override || "#{fetch(:stage)}.sql.bz2"
    puts "- Dump file....: #{file_name}"

    on roles(:app) do
      if action.to_s.empty?
        info('Running remote db:dump...')
        execute(:docker, "exec #{fetch(:app_service)} sh -c 'bundle exec rails db:dump'")

      elsif action == 'get'
        info("Downloading #{file_name} remote dump file into /db/dump ...")
        download!(File.join(fetch(:backup_path), file_name), File.join('.', 'db', 'dump', file_name))

      elsif action == 'put'
        info("Uploading /db/dump/#{file_name} local dump file into /backups ...")
        upload!(File.join('.', 'db', 'dump', file_name), File.join(fetch(:backup_path), file_name))
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
    Runs remotely the 'db:rebuild' task for the specified deploy stage.

    The 'db:rebuild' rake task recreates from scratch the target DB, named as the stage,
    using the current dump stored inside the remote 'db/dump' folder (a compressed DB dump file
    conveniently named after the running Rails environment).
    These dumps can be easily created with the counterpart 'db:dump' task.

    On the remote host, the 'db/dump' folder is usually mapped onto the '/backups' directory.
    A dump file name override can also be set.


    ** Usage: **

      > cap <STAGE> db:rebuild

      Run the remote task, restoring the whole DB from 'backups/<STAGE>.sql.bz2'

    Or:
      > cap <STAGE> db:rebuild[from=<BASE_FILENAME>]

      Same as above, but uses the remote dump file named 'db/dump/<BASE_FILENAME>.sql.bz2'.
      (Only the 'from' option is supported: the destination will always be tied to the stage name)

  DESC
  task :rebuild, :action do |_t, args|
    display_common_header
    action, name_override = args[:action].to_s.split('=')
    file_name = name_override || fetch(:stage)
    puts "- Dump file....: #{file_name}"

    on roles(:app) do
      if action.to_s.empty?
        info('Running remote db:rebuild...')
        execute(:docker, "exec #{fetch(:app_service)} sh -c 'bundle exec rails db:rebuild'")

      elsif action == 'from'
        info("Running remote db:rebuild using the 'from' option...")
        execute(:docker, "exec #{fetch(:app_service)} sh -c 'bundle exec rails db:rebuild from=#{name_override}'")
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
    Loops on all the '.sql' files found in a specified directory, uploads and executes them in
    alphabetical order on the remote host, one by one, using the corresponding <STAGE> database.

    When successfully run, each uploaded '.sql' file is consumed (deleted); errors and warnings
    are intercepted and presented on the console. In case of errors, the loop is halted.

    The source folder files are always left untouched (not moved nor consumed in any case).

    A source folder override can be specified as additional argument to the task.
    The 'mysql' client must be installed on the host.


    ** Defaults: **

    - source folder => 'localhost: <RAILS_ROOT>/tmp'
    - dest. folder  => 'host: /tmp' (erased afterwards when ok)


    ** Usage: **

      > cap <STAGE> db:exec

      Upload all 'tmp/*.sql' files and execute them one-by-one on the <STAGE> database;
      each destination file is deleted after the execution, except in case of errors.

    Or:
      > cap <STAGE> db:exec[tmp/diff]

      Same as above, but uploads all 'tmp/diff/*.sql' files instead.

  DESC
  task :exec, :source_folder do |_t, args|
    display_common_header
    source_folder = args[:source_folder] || 'tmp'
    puts "- Source.......: #{source_folder}/*.sql"
    sql_filenames = Dir.glob([File.join('.', source_folder, '*.sql')])
    puts "  => #{sql_filenames.size} total SQL files to be processed."
    # Use a custom temp file for stderr redirection:
    stderr_filename = '/tmp/stderr_log.txt'

    on roles(:app) do
      sql_filenames.each_with_index do |filename, index|
        info "\r\nUploading file #{index + 1}/#{sql_filenames.size}: #{filename} ..."
        upload! filename, '/tmp/sql_exec_upload.sql'
        execute(
          :mysql,
          "--host=0.0.0.0 --port=#{fetch(:db_port)} --database=#{fetch(:db_name)} \
            --user=#{fetch(:db_user)} --password=\"#{fetch(:db_password)}\" \
            -e \"\\. /tmp/sql_exec_upload.sql\" 2> #{stderr_filename}"
        )

        # Intercept errors or warnings on the stderr output:
        next unless test("[ -s #{stderr_filename} ]")

        output_lines = capture(:cat, stderr_filename).split("\n")
        errors = output_lines.grep(/ERROR/i)
        warnings = output_lines.grep(/Warning/i)
        if errors.size.positive?
          puts "\r\nError(s) intercepted!"
          display_captured_output(errors)
          puts "\r\nAborting..."
          exit(1)
        end
        next unless warnings.size.positive?

        puts "\r\nWarning(s) intercepted:"
        display_captured_output(warnings)
        puts "\r\nIgnoring..."
      end

      # Post-run: consume tmp files on dest host:
      info('Removing remote tmp files...')
      execute(:rm, stderr_filename)
      execute(:rm, '/tmp/sql_exec_upload.sql')
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
