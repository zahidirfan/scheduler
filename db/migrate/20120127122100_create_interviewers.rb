class CreateInterviewers < ActiveRecord::Migration
  def change
    create_table :interviewers do |t|
      t.integer :interview_id
      t.integer :user_id
      t.string
      t.timestamps
    end
  end
end
