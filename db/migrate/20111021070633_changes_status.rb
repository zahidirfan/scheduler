class ChangesStatus < ActiveRecord::Migration
  def up
    remove_column :candidates, :status_id
    add_column :candidates, :status, :string
  end

  def down
  end
end
