# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Bundler::OrderedGems, :config do
  subject(:cop) { described_class.new(config) }

  context 'When gems are alphabetically sorted' do
    let(:source) { <<-END }
      gem 'rspec'
      gem 'rubocop'
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When gems are not alphabetically sorted' do
    let(:source) { <<-END }
      gem 'rubocop'
      gem 'rspec'
    END

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'mentions both gem names in message' do
      inspect_source(cop, source)
      expect(cop.offenses.first.message).to include('rspec')
      expect(cop.offenses.first.message).to include('rubocop')
    end

    it 'highlights the second gem' do
      inspect_source(cop, source)
      expect(cop.highlights).to eq(["gem 'rspec'"])
    end
  end

  context 'When each individual group of line is sorted' do
    let(:source) { <<-END }
      gem 'rspec'
      gem 'rubocop'

      gem 'hello'
      gem 'world'
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When a gem declaration takes several lines' do
    let(:source) { <<-END }
      gem 'rubocop',
          '0.1.1'
      gem 'rspec'
    END

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'When the gemfile is empty' do
    let(:source) { <<-END }
      # Gemfile
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  it 'autocorrects' do
    source = <<-END
      gem "d"
      gem "b"
      gem "e"
      gem "a"
      gem "c"

      gem "h"
      gem "g"
      gem "j"
      gem "f"
      gem "i"
    END

    new_source = autocorrect_source_with_loop(cop, source)
    expect(new_source).to eq(['      gem "a"',
                              '      gem "b"',
                              '      gem "c"',
                              '      gem "d"',
                              '      gem "e"',
                              '',
                              '      gem "f"',
                              '      gem "g"',
                              '      gem "h"',
                              '      gem "i"',
                              '      gem "j"',
                              ''].join("\n"))
  end
end
