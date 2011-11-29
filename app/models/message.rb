class Message
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming

  attr_accessor :name, :email, :subject, :description, :resume

  validates :name, :email, :subject, :description, :resume, :presence => true
  validate :email, :format => { :with => %r{.+@.+\..+} }, :allow_blank => true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
