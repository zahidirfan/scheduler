class AddSubjectToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :subject, :string
  end
end
