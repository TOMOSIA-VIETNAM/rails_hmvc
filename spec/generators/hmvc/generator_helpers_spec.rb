# frozen_string_literal: true

RSpec.describe RailsHmvc::Generators::GeneratorHelpers do
  let(:helper_class) do
    Class.new(Rails::Generators::Base) do
      include RailsHmvc::Generators::GeneratorHelpers
    end
  end

  let(:dest) { Dir.mktmpdir }
  let(:helper) { helper_class.new([], {}, destination_root: dest) }

  after do
    FileUtils.rm_rf(dest)
  end

  describe "#load_config" do
    it "returns {} when file is missing" do
      expect(helper.send(:load_config)).to eq({})
    end

    it "loads YAML with merge keys (aliases)" do
      FileUtils.mkdir_p(File.join(dest, "config"))
      File.write(
        File.join(dest, "config", "rails_hmvc.yml"),
        <<~YAML
          defaults: &defaults
            type: api
          api:
            <<: *defaults
            controllers:
              parent: MainController
              actions: [index]
        YAML
      )
      cfg = helper.send(:load_config)
      expect(cfg.dig("api", "type")).to eq("api")
      expect(cfg.dig("api", "controllers", "parent")).to eq("MainController")
    end

    it "falls back to second safe_load when the first returns nil" do
      FileUtils.mkdir_p(File.join(dest, "config"))
      File.write(File.join(dest, "config", "rails_hmvc.yml"), "k: v\n")
      calls = 0
      allow(YAML).to receive(:safe_load).and_wrap_original do |m, *args, **kwargs|
        calls += 1
        next nil if calls == 1

        m.call(*args, **kwargs)
      end
      cfg = helper.send(:load_config)
      expect(cfg["k"]).to eq("v")
    end

    it "retries without aliases when the first safe_load raises" do
      FileUtils.mkdir_p(File.join(dest, "config"))
      File.write(File.join(dest, "config", "rails_hmvc.yml"), "k: v\n")
      allow(YAML).to receive(:safe_load).and_wrap_original do |m, *args, **kwargs|
        raise StandardError, "alias parse" if kwargs[:aliases]

        m.call(*args, **kwargs)
      end
      cfg = helper.send(:load_config)
      expect(cfg["k"]).to eq("v")
    end

    it "returns {} when the second safe_load raises" do
      FileUtils.mkdir_p(File.join(dest, "config"))
      File.write(File.join(dest, "config", "rails_hmvc.yml"), "k: v\n")
      allow(YAML).to receive(:safe_load).and_wrap_original do |_m, *_args, **kwargs|
        next nil if kwargs[:aliases]

        raise StandardError, "second parse"
      end
      expect(helper.send(:load_config)).to eq({})
    end

    it "returns {} on outer failure when File.read raises" do
      FileUtils.mkdir_p(File.join(dest, "config"))
      path = File.join(dest, "config", "rails_hmvc.yml")
      File.write(path, "k: v\n")
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(path).and_raise(StandardError.new("readfail"))
      allow(Rails.logger).to receive(:debug)
      expect(helper.send(:load_config)).to eq({})
      expect(Rails.logger).to have_received(:debug)
    end
  end

  describe "#load_config_for_type" do
    before do
      FileUtils.mkdir_p(File.join(dest, "config"))
      File.write(
        File.join(dest, "config", "rails_hmvc.yml"),
        <<~YAML
          type: api
          shared: root
          api:
            controllers:
              parent: ApiMain
              actions: [index]
          web:
            controllers:
              parent: WebMain
              actions: [index]
        YAML
      )
    end

    it "merges base and api by default from file type" do
      cfg = helper.send(:load_config_for_type)
      expect(cfg["type"]).to eq("api")
      expect(cfg["shared"]).to eq("root")
      expect(cfg.dig("controllers", "parent")).to eq("ApiMain")
    end

    it "merges explicit type" do
      cfg = helper.send(:load_config_for_type, "web")
      expect(cfg.dig("controllers", "parent")).to eq("WebMain")
    end

    it "returns empty merge when yaml is empty" do
      File.write(File.join(dest, "config", "rails_hmvc.yml"), "{}\n")
      cfg = helper.send(:load_config_for_type)
      expect(cfg).to eq({})
    end
  end

  describe "#namespace_path and #namespace_name" do
    let(:named) do
      Class.new(Rails::Generators::NamedBase) do
        include RailsHmvc::Generators::GeneratorHelpers
      end
    end

    it "joins class_path for namespace_path and camelizes namespace_name" do
      g = named.new(["v1/users"], {}, destination_root: dest)
      expect(g.send(:namespace_path)).to eq("v1")
      expect(g.send(:namespace_name)).to eq("V1")
    end

    it "strips a leading slash typo from namespace_path and namespace_name" do
      g = named.new(["/v1/users"], {}, destination_root: dest)
      expect(g.send(:namespace_path)).to eq("v1")
      expect(g.send(:namespace_name)).to eq("V1")
    end

    it "strips multiple leading slashes" do
      g = named.new(["//v1/users"], {}, destination_root: dest)
      expect(g.send(:namespace_path)).to eq("v1")
      expect(g.send(:namespace_name)).to eq("V1")
    end

    it "strips embedded double-slash typo" do
      g = named.new(["v1//users"], {}, destination_root: dest)
      expect(g.send(:namespace_path)).to eq("v1")
      expect(g.send(:namespace_name)).to eq("V1")
    end
  end

  describe "#singular_human_name" do
    let(:named) do
      Class.new(Rails::Generators::NamedBase) do
        include RailsHmvc::Generators::GeneratorHelpers
      end
    end

    it "singularizes human_name" do
      g = named.new(["v1/users"], {}, destination_root: dest)
      expect(g.send(:singular_human_name)).to eq("User")
    end
  end
end
