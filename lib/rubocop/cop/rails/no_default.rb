# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for migrations which set defaults -
      # they're not allowed unless they're part of a create_table block
      #
      # @example
      #   # bad
      #   add_column :users, :name, :string, null: false, default: ''
      #   add_column :users, :name, :string, null: true, default: ''
      #   change_column :users, :name, :string, default: ''
      #
      #   # good
      #   add_column :users, :name, :string, null: true
      #   create_table :users do |t|
      #     t.column :name, :string, :null: false, default: ''
      #   end
      class NoDefault < Cop
        MSG = 'Do not set default values outside table creation.'.freeze

        def_node_matcher :add_or_change_column?, <<-PATTERN
          (send nil {:add_column :change_column} _ _ _ (hash $...))
        PATTERN

        def_node_matcher :has_default?, <<-PATTERN
          (pair (sym :default) !(:nil))
        PATTERN

        def on_send(node)
          pairs = add_or_change_column?(node)
          return unless pairs
          has_default = pairs.find { |pair| has_default?(pair) }
          return unless has_default

          add_offense(has_default, :expression)
        end
      end
    end
  end
end
