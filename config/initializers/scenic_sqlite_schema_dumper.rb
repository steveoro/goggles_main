# frozen_string_literal: true

# Scenic's MySQL view dumper is installed globally, including for SQLite support DBs.
# Skip view discovery there while retaining normal SQLite table/schema dumping.
module ScenicSqliteSchemaDumper
  def views(stream)
    super unless @connection.adapter_name == 'SQLite'
  end

  private

  def defined_views
    @connection.adapter_name == 'SQLite' ? [] : super
  end
end

ActiveRecord::SchemaDumper.prepend(ScenicSqliteSchemaDumper)
