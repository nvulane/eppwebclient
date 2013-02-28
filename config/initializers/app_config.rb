AppConfig = YAML.load(File.read(Rails.root + 'config' + 'app_config.yml'))[Rails.env].with_indifferent_access
