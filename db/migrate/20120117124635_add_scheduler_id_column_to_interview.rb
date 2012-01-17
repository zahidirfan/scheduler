class AddSchedulerIdColumnToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :scheduler_id, :integer
  end
end
