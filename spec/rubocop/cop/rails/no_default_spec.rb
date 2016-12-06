# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::NoDefault, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Include' => nil } }

  before do
    inspect_source(cop, source)
  end

  context 'with add_column call' do
    context 'with a default' do
      let(:source) { 'add_column :users, :name, :string, default: ""' }
      it 'reports an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(
          ['Do not set default values outside table creation.']
        )
      end
    end

    context 'with null: true and no default' do
      let(:source) do
        'add_column :users, :name, :string, null: true'
      end
      include_examples 'accepts'
    end

    context 'with null: false and default: nil' do
      let(:source) do
        'add_column :users, :name, :string, null: false, default: nil'
      end
      include_examples 'accepts'
    end

    context 'without any options' do
      let(:source) { 'add_column :users, :name, :string' }
      include_examples 'accepts'
    end
  end

  context 'with change_column call' do
    context 'with no default' do
      let(:source) { 'change_column :users, :name, :string, null: true' }
      include_examples 'accepts'
    end

    context 'with a default' do
      let(:source) do
        'change_column :users, :name, :string, null: true, default: ""'
      end
      it 'reports an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(
          ['Do not set default values outside table creation.']
        )
      end
    end
  end

  context 'with create_table call' do
    let(:source) do
      ['class CreateUsersTable < ActiveRecord::Migration',
       '  def change',
       '    create_table :users do |t|',
       '      t.string :name, null: false, default: ""',
       '      t.timestamps null: false',
       '    end',
       '  end',
       'end']
    end
    include_examples 'accepts'
  end
end
