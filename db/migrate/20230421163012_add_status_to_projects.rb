# frozen_string_literal: true

class AddStatusToProjects < ActiveRecord::Migration[7.0]
  def up
    create_enum :project_status, %w[todo in_progress completed]

    change_table :projects do |t|
      t.enum :status, enum_type: 'project_status', default: 'todo', null: false
    end
  end

  def down
    remove_column :projects, :status
    execute <<-SQL.squish
      DROP TYPE project_status;
    SQL
  end
end
