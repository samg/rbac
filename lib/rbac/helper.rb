module Rbac::Helper
  # TODO: Test!
  def rbac provider, &block
    RbacProcessor.new(provider, self).instance_eval &block
  end

  def rbac_has_permission? provider='*', operation='*', rule='*'
    Rbac.current_user.has_permission? Rbac::Operation.permission_identifier(provider.class, operation, rule)
  end

  class RbacProcessor
    attr_accessor :provider, :receiver
    def initialize provider, receiver
      self.provider, self.receiver = provider, receiver
    end

    def allowed? operation='*', rule='*'
      pass :rbac_has_permission?, provider, operation, rule
    end

    def pass method, *args, &block
      receiver.send method, *args, &block
    end

    def method_missing method, *args, &block
      pass method, *args, &block
    end

    def respond_to? method
      super(method) || receiver.respond_to?(method)
    end
  end
end
