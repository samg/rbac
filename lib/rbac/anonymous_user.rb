class Rbac::AnonymousUser
  include ::Rbac::Subject
  def roles
    [Rbac::AnonymousRole.new]
  end
end
