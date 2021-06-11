# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# == Bundler ==

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end
#-- ---------------------------------------------------------------------------
#++

# == Rubocop ==

rubocop_options = {
  cmd: 'bin/rubocop',
  cli: '-f fu'
}
guard :rubocop, rubocop_options do
  watch(/.+\.rb$/)
  watch(/.+\.rake$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end
#-- ---------------------------------------------------------------------------
#++

# == Brakeman ==

brakeman_options = {
  cmd: 'bundle exec brakeman',
  cli: '-A',
  run_on_start: true,
  quiet: true,
  chatty: true
}
guard :brakeman, brakeman_options do
  watch(%r{^app/.+\.(erb|haml|rhtml|rb)$})
  watch(%r{^config/.+\.rb$})
  watch(%r{^lib/.+\.rb$})
  watch('Gemfile')
end
#-- ---------------------------------------------------------------------------
#++

# == RSpec ==

# NOTE: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'
rspec_options = {
  cmd: 'bin/rspec',
  # Exclude performance tests; to make it fail-fast, add option "--fail-fast":
  cmd_additional_args: ' --color --profile 10 -f progress --order rand -t ~type:performance -t ~tag:performance',
  all_after_pass: false,
  failed_mode: :focus
}
guard :rspec, rspec_options do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails(view_extensions: %w[erb haml slim])
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  # In case a controller changes, run a corresponding spec for each one of these cases:
  watch(rails.controllers) do |m|
    [
      rspec.spec.call("routing/#{m[1]}_routing"),
      rspec.spec.call("requests/#{m[1]}_request"),
      rspec.spec.call("acceptance/#{m[1]}")
    ]
  end

  # Rails config changes
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.routes)          { "#{rspec.spec_dir}/routing" }

  # Watch split spec files, due to multiple long contexts:
  watch('app/strategies/solver/lookup_entity.rb') { Dir.glob('spec/strategies/solver/lookup_entity*_spec.rb') }

  # Watch controller specs directly as requests:
  watch(rails.app_controller)  { "#{rspec.spec_dir}/requests" }

  # Capybara features specs
  watch(rails.view_dirs)     { |m| rspec.spec.call("features/#{m[1]}") }
  watch(rails.layouts)       { |m| rspec.spec.call("features/#{m[1]}") }
end
#-- ---------------------------------------------------------------------------
#++

# == Spring ==

guard 'spring', bundler: true do
  watch('Gemfile.lock')
  watch(%r{^config/})
  watch(%r{^spec/(support|factories)/})
  watch(%r{^spec/factory.rb})
end
#-- ---------------------------------------------------------------------------
#++

# == Inch - documentation grader ==

# - use all_type: :stats for
guard :inch, pedantic: false, private: false, all_on_start: true, all_type: :suggest do
  watch(/.+\.rb/)
end
#-- ---------------------------------------------------------------------------
#++

# == HAML-Lint ==

# Guard-HamlLint supports a lot options with default values:
# all_on_start: true            # Check all files at Guard startup. default: true
# haml_dires: ['app/views']     # Check Directories. default: 'app/views' or '.'
# cli: '--fail-fast --no-color' # Additional command line options to haml-lint.
guard :haml_lint do
  watch('.haml-lint.yml')
  watch(/.+\.html.*\.haml$/)
  watch(%r{(?:.+/)?\.haml-lint\.yml$}) { |m| File.dirname(m[0]) }
end

# == ESLint / StandardJS ==

guard :shell do
  watch(%r{app/(components|javascript)/.+\.js$}) { |m| `yarn lint #{m[0]}` }
end
#-- ---------------------------------------------------------------------------
#++

# == Cucumber ==

cucumber_options = {
  cmd: 'AUTO_ARTIFACTS=1 cucumber',
  cmd_additional_args: '--profile guard',
  notification: false, all_after_pass: false, all_on_start: false
}

# Watch everything Cucumber-related and run it:
guard :cucumber, cucumber_options do
  # Watch for feature updates:
  watch(%r{^features/(.+/)?(.+)\.feature$}) do |m|
    puts "'#{m[0]}' modified..."
    m[0]
  end
  # Watch for support file updates (will trigger a re-run of all features):
  watch(%r{^features/support/.+$}) do |m|
    puts "'#{m[0]}' support file modified..."
    Dir[File.join("features\/\*\*\/*.feature")]
  end
  # Watch for step definition updates (will trigger a re-run of a whole feature):
  watch(%r{^features/step_definitions/(.+/)?(.+)_steps\.rb$}) do |m|
    puts "'#{m[1]}' steps file modified..."
    Dir[File.join("features\/\*\*\/*#{m[1]}*.feature")]
  end
end
