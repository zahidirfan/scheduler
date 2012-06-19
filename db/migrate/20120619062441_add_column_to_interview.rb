class AddColumnToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :status, :boolean
  end
end
