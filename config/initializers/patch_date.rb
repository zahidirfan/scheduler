class Date
  def self.today
    DateTime.current.to_date
  end

  def self.tomorrow
    self.today + 1
  end
end
