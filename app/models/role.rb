class Role < ActiveRecord::Base
  include Rbac::Role
  class Super; include Rbac::Role; def permissions; [Rbac::SimplePermission.new('*.*.*')]; end; end
  has_and_belongs_to_many :users
  has_and_belongs_to_many :permissions

  validates_uniqueness_of :name
  validates_presence_of   :name
  validates_format_of     :name, :with => /\A[\d\w\s_-]+\Z/,
    :message => 'may contain letters, numbers, dashes, and underscores'
  def to_param; name; end

  def permissions_with_identifiers=(perms)
    if perms.is_a? Hash
      perms = perms.map do |id, bool|
        Permission.find_or_initialize_by_identifier(id) if
          ['1', 1, true].include?(bool)
      end.compact
    end
    self.permissions_without_identifiers=(perms)
  end
  alias_method_chain :permissions=, :identifiers
end
