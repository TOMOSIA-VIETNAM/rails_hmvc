# frozen_string_literal: true

module RailsHmvcGeneratorConfig
  def self.api_yaml
    {
      "type" => "api",
      "api" => {
        "controllers" => {
          "parent" => "MainController",
          "actions" => %w[index show create update destroy]
        },
        "operations" => { "parent" => "MainOperation", "steps" => %w[validate persist] },
        "forms" => { "parent" => "MainForm", "actions" => %w[create update], "skip_actions" => [] }
      }
    }
  end

  def self.web_yaml
    {
      "type" => "web",
      "web" => {
        "controllers" => {
          "parent" => "MainController",
          "actions" => %w[index show new create edit update destroy]
        },
        "operations" => { "parent" => "MainOperation", "steps" => %w[validate] },
        "forms" => { "parent" => "MainForm", "actions" => %w[create update destroy], "skip_actions" => %w[destroy] }
      }
    }
  end

  def self.write_config(root, hash)
    FileUtils.mkdir_p(File.join(root, "config"))
    File.write(File.join(root, "config", "rails_hmvc.yml"), YAML.dump(hash))
  end
end
