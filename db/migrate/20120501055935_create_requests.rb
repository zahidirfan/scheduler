class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :status
      t.integer :interview_id
      t.integer :user_id
      t.datetime :reschedule_date
      t.text :message

      t.timestamps
    end
  end
end
