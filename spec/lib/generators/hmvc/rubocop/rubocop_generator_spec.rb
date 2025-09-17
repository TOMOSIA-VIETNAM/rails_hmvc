require 'spec_helper'
require 'generators/hmvc/rubocop/rubocop_generator'

RSpec.describe RailsHmvc::Generators::RubocopGenerator do
  let(:generator) { described_class.new }

  before do
    allow(generator).to receive(:system).and_return(true)
    allow(generator).to receive(:create_file)
    allow(generator).to receive(:copy_file)
    allow(generator).to receive(:chmod)
    allow(generator).to receive(:empty_directory)
  end

  describe '#create_rubocop_config' do
    context 'when .rubocop.yml does not exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it 'creates a basic rubocop config file' do
        generator.create_rubocop_config

        expect(generator).to have_received(:create_file)
          .with('.rubocop.yml', kind_of(String))
        expect(generator).to have_received(:create_file)
          .with('bin/rubocop-hmvc', kind_of(String))
        expect(generator).to have_received(:chmod)
          .with('bin/rubocop-hmvc', 0o755)
      end
    end

    context 'when .rubocop.yml exists' do
      before do
        allow(File).to receive(:exist?).with('.rubocop.yml').and_return(true)
      end

      context 'without --force option' do
        it 'does not overwrite config' do
          generator.create_rubocop_config

          expect(generator).not_to have_received(:create_file)
        end
      end

      context 'with --force option' do
        let(:generator) { described_class.new([], force: true) }

        before do
          allow(File).to receive(:exist?) do |path|
            if path == '.rubocop.yml'
              true
            elsif path.include?('.rubocop.yml.example')
              false
            else
              false
            end
          end
        end

        it 'overwrites the config file' do
          generator.create_rubocop_config

          expect(generator).to have_received(:create_file)
            .with('.rubocop.yml', kind_of(String))
          expect(generator).to have_received(:chmod)
            .with('bin/rubocop-hmvc', 0o755)
        end
      end
    end
  end
end
