module MyActiveRecordExtensions

  def random_record
    if self.class == "Candidate"
      where("status != ?", "Scheduled").order('RAND()').limit(1)
    else
      order('RAND()').limit(1)
    end
  end

end

ActiveRecord::Base.send(:extend, MyActiveRecordExtensions)
