# You will want to set default_permissions in your application
class Rbac::AnonymousRole
  include ::Rbac::Role
  cattr_accessor :default_permissions

  def permissions
    self.class.default_permissions || []
  end
end
