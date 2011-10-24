class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :description
      t.integer :user_id
      t.integer :interview_id
      t.string :status
      t.integer :candidate_id

      t.timestamps
    end
  end
end