# frozen_string_literal: true

class CreateProjectHistoryEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :project_history_entries, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid

      t.string :type, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
