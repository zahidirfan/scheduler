class AddArchiveToCandidate < ActiveRecord::Migration
  def change
    add_column :candidates, :archive, :boolean, :default => false
  end
end
