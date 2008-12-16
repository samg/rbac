module Rbac::Operation
  class AuthorizationError < StandardError; end

  def self.operation_identifier klass, operation
    klass.to_s.underscore.to_s + '.' + operation.to_s.underscore
  end

  def self.permission_identifier klass, operation, rule, options = {}
    str = operation_identifier(klass, operation) + '.'
    str << '!' if options[:negate]
    str << rule.to_s.underscore
  end

  def self.included base
    super base
    initialize_active_record(base) if base.ancestors.include? ActiveRecord::Base
    initialize_action_controller(base) if base.ancestors.include? ActionController::Base
    base.extend ClassMethods
  end

  def self.initialize_active_record base
    # ActiveRecord won't call the after_initialize callback unless an empty
    # after_initialize instance method is defined.
    unless base.instance_methods.include?('after_initialize')
      base.send :define_method, :after_initialize, &lambda{}
    end

    callback_operations = {
      :before_create => :create, :after_initialize => :read,
      :before_update => :update, :before_destroy => :destroy
    }
    callback_operations.each do |callback, operation|
      base.send callback, lambda{|m|m.enforce_rbac!(operation)}
    end

    base.metaclass.send :define_method, :operations, lambda {
      [:create, :read, :update, :destroy]
    }
  end

  def self.initialize_action_controller base
    base.send :before_filter, &lambda{|c|c.enforce_rbac!(c.action_name)}
  end

  def enforce_rbac! operation
    raise AuthorizationError, describe_denial(operation) unless
      enforcer.ok?(operation)
  end

  def enforcer
    @enforcer ||= Rbac::Operation::Enforcer.new self
  end

  private
  def describe_denial operation
    "OPERATION `#{operation}' DENIED ON #{enforcer.base.class} " +
    "for #{Rbac.current_user.inspect} with " +
    "permissions #{Rbac.current_user.permissions.map(&:identifier).inspect}"
  end

  module ClassMethods
    def self.extended base
      base.send :class_inheritable_accessor, :rbac_rules
      base.rbac_rules = {}
    end

    def define_rbac_rule name, description, &rule
      self.rbac_rules[name] = {:description => description, :rule => rule}
    end

    def label
      to_s.demodulize.underscore.humanize
    end
  end
end
