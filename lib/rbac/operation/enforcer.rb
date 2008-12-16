# Enforcer provides an interface for checking permissions statically and with
# context.
class Rbac::Operation::Enforcer
  attr_accessor :base, :current_operation

  def initialize base
    self.base = base
    base.rbac_rules.each do |rule, definition|
      metaclass.send :define_method, rule,
        lambda{base.instance_eval(&definition[:rule])}
    end
  end

  def descriptions
    base.class.rbac_rules.map{|r,d|d[:description]}
  end

  def ok? operation
    self.current_operation = operation
    identifier = Rbac::Operation.operation_identifier(base.class, operation)
    Rbac.current_user.has_permission?(identifier, self)
  ensure
    self.current_operation = nil
  end

  def ok_permissions operation_identifier, *permissions
    instance_eval &self.class.permission_lambda(operation_identifier, *permissions)
  end

  def self.ok_permissions operation_identifier, *permissions
    instance_eval &permission_lambda(operation_identifier, *permissions)
  end

  private
  def self.permission_lambda operation_identifier, *permissions
    lambda do
      provider, operation, rule = operation_identifier.split('.', 3)
      permissions.select do |perm|
        p, o, r = perm.split('.')
        ok_provider?(provider, p) && ok_operation?(operation, o) &&
          ok_rule?(rule, r)
      end
    end
  end

  def self.ok_provider? target, candidate
    candidate == '*' ||
    ancestor_matches?(target, candidate) ||
    target.to_s == candidate.to_s
  end
  def ok_provider?(*args); self.class.ok_provider?(*args); end

  def self.ancestor_matches? target, candidate
    klass = target.classify.constantize rescue (return false)
    klass.ancestors.map{|a| a.to_s.underscore}.any?{|a| a == candidate}
  end

  def self.ok_operation? target, candidate
    candidate == '*' ||
    target.to_s == candidate.to_s
  end
  def ok_operation?(*args); self.class.ok_operation?(*args); end

  def self.ok_rule? target, candidate
    candidate == '*'
  end

  def ok_rule? target, candidate
    return true if candidate == '*'
    negate = false
    if candidate.starts_with?('!')
      negate = true
      candidate = candidate.split("!", 2).last
    end
    ret = send candidate
    negate ? !ret : ret
  end
end
