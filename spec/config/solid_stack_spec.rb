# frozen_string_literal: true

require 'rails_helper'

module SolidStack
end

RSpec.describe SolidStack do
  let(:repo_root) { Rails.root }

  def load_yaml(path)
    YAML.safe_load_file(repo_root.join(path), aliases: true, permitted_classes: [Symbol])
  end

  describe 'database.docker.yml' do
    let(:config) { load_yaml('config/database.docker.yml') }

    %w[production staging].each do |env|
      it "defines cache, queue, and cable roles for #{env}" do
        roles = config.fetch(env).keys
        expect(roles).to include('primary', 'cache', 'queue', 'cable')
      end
    end

    it 'uses ruby schema format for sqlite support databases' do
      %w[production staging development test].each do |env|
        config.fetch(env).except('primary').each do |role, role_config|
          expect(role_config['schema_format']).to eq(:ruby), "expected :ruby for #{env}.#{role}"
        end
      end
    end

    it 'does not disable schema dumps on support databases' do
      %w[production staging development test].each do |env|
        config.fetch(env).except('primary').each_value do |role_config|
          expect(role_config).not_to have_key('schema_dump')
        end
      end
    end
  end

  %w[config/database.yml config/database.example.yml config/database_ci.yml].each do |path|
    describe path do
      let(:config) { load_yaml(path) }

      it 'defines production cable role with ruby schema format' do
        cable = config.fetch('production').fetch('cable')
        expect(cable['adapter']).to eq('sqlite3')
        expect(cable['schema_format']).to eq(:ruby)
        expect(cable['database']).to include('production_cable.sqlite3')
      end
    end
  end

  describe 'config/cache.yml' do
    let(:cache_config) { load_yaml('config/cache.yml') }

    it 'points production and staging at the cache database role' do
      expect(cache_config.fetch('production')['database']).to eq('cache')
      expect(cache_config.fetch('staging')['database']).to eq('cache')
    end
  end

  describe 'config/cable.yml' do
    let(:cable_config) { load_yaml('config/cable.yml') }

    it 'uses solid_cable with the cable database role in deployed environments' do
      %w[production staging].each do |env|
        expect(cable_config.fetch(env)['adapter']).to eq('solid_cable')
        expect(cable_config.fetch(env).dig('connects_to', 'database', 'writing')).to eq('cable')
      end
    end
  end

  describe 'config/environments/production.rb' do
    let(:production_rb) { repo_root.join('config/environments/production.rb').read }

    it 'configures Solid Queue and Solid Cache once' do
      expect(production_rb.scan('config.active_job.queue_adapter = :solid_queue').length).to eq(1)
      expect(production_rb.scan('config.cache_store = :solid_cache_store').length).to eq(1)
      expect(production_rb).to include('Rails.application.credentials.smtp')
      expect(production_rb).to include("host: 'master-goggles.org'")
    end
  end

  describe 'docker-compose.prod.yml' do
    let(:compose) { repo_root.join('docker-compose.prod.yml').read }

    it 'mounts the master key but not production.rb' do
      expect(compose).to include('master-main.key')
      expect(compose).not_to include('production.rb')
    end
  end

  describe 'support database schema files' do
    include ActiveRecord::Tasks::DatabaseTasks

    def support_schema_loaded?(role, schema_path, sentinel_table)
      config = ActiveRecord::DatabaseConfigurations::HashConfig.new(
        'test',
        role,
        {
          'adapter' => 'sqlite3',
          'database' => ':memory:',
          'schema_format' => 'ruby'
        }
      )

      with_temporary_connection(config, clobber: true) do |connection|
        load_schema(config, :ruby, repo_root.join(schema_path).to_s)
        connection.table_exists?(sentinel_table)
      end
    end

    it 'loads db/cache_schema.rb' do
      expect(support_schema_loaded?('cache', 'db/cache_schema.rb', 'solid_cache_entries')).to be(true)
    end

    it 'loads db/queue_schema.rb' do
      expect(support_schema_loaded?('queue', 'db/queue_schema.rb', 'solid_queue_jobs')).to be(true)
    end

    it 'loads db/cable_schema.rb' do
      expect(support_schema_loaded?('cable', 'db/cable_schema.rb', 'solid_cable_messages')).to be(true)
    end
  end
end
