class RemoveScheduleTimeFromInterview < ActiveRecord::Migration
  def up
    remove_column :interviews, :schedule_time
  end

  def down
    add_column :interviews, :schedule_time, :string
  end
end
