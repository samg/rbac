require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :logs
  alias_attribute :email_address, :email
  after_create :notify_admin

  include Rbac::Subject
  has_and_belongs_to_many :roles
  class Super; include Rbac::Subject; def roles; [Role::Super.new]; end; end

  def roles_with_identifier= roles
    if roles.is_a? Hash
      roles = roles.map do |r, bool|
        Role.find_by_name(r) if ['1', 1, true].include?(bool)
      end.compact
    end
    self.roles_without_identifier=(roles)
  end
  alias_method_chain :roles=, :identifier

  def name
    [first_name, last_name].join(' ').strip
  end

  # Let an admin know when someone logs in through appleconnect for the first time.
  def notify_admin
    UserNotifier.deliver_new_user_notification self
  end

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of      :email
  validates_uniqueness_of   :login, :allow_blank => true

  before_save :encrypt_password

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :email_address, :password, :roles,
    :first_name, :last_name, :prs_id

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
