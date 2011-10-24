class ChangesToCandidates < ActiveRecord::Migration
  def up
    add_column :candidates, :email, :string
    add_column :candidates, :mobile, :string
    add_column :candidates, :phone, :string
    remove_column :candidates, :project_id
    remove_column :candidates, :user_id
  end

  def down
    remove_column :candidates, :email
    remove_column :candidates, :mobile
    remove_column :candidates, :phone
    add_column :candidates, :project_id, :integer
    add_column :candidates, :user_id, :integer
  end
end
