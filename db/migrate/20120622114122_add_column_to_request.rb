class AddColumnToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :comment, :text
  end
end
