class AddResumetoCandidate < ActiveRecord::Migration
  def up
    add_column :candidates, :resume_file_name,    :string
    add_column :candidates, :resume_content_type, :string
    add_column :candidates, :resume_file_size,    :integer
    add_column :candidates, :resume_updated_at,   :datetime
  end

  def down
    remove_column :candidates, :resume_file_name
    remove_column :candidates, :resume_content_type
    remove_column :candidates, :resume_file_size
    remove_column :candidates, :resume_updated_at
    
  end
end
