class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles
  validates_uniqueness_of :provider, :scope => [:operation, :rule],
    :message => "Provider, Operation, Rule combination must be unique"

  def identifier
    [provider, operation, rule].map{|x|x.nil? ? '*' : x}.join('.')
  end

  def self.find_by_identifier(identifier)
    find :first, :conditions => identifier_to_attributes(identifier)
  end

  def self.initialize_by_identifier(identifier)
    new identifier_to_attributes(identifier)
  end

  def self.find_or_initialize_by_identifier(identifier)
    find_by_identifier identifier or initialize_by_identifier identifier
  end

  private
  def self.identifier_to_attributes(identifier)
    p, o, r = *identifier.split('.').map{|x| x == '*' ? nil : x }
    {:provider => p, :operation => o, :rule => r}
  end

end
