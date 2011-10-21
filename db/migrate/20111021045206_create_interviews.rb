class CreateInterviews < ActiveRecord::Migration
  def change
    create_table :interviews do |t|
      t.date :scheduled_at
      t.string :schedule_time
      t.integer :candidate_id
      t.integer :user_id
      t.timestamps
    end
  end
end
