class AddEndtimeToInterview < ActiveRecord::Migration
  def change
    change_column :interviews, :scheduled_at, :datetime
    add_column :interviews, :endtime, :datetime
  end
end
