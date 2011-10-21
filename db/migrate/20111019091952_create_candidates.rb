class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.string :name
      t.integer :project_id
      t.integer :user_id
      t.integer :status_id
      t.integer :priority_id
      t.timestamps
    end
  end
end
