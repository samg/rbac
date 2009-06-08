# This Rbac interface is inspired by ActiveRbac, detailed at:
# http://active-rbac.rubyforge.org/docs/002_arbac_schema.html#rbac_schema_level_2
#
# Read http://en.wikipedia.org/wiki/Role-based_access_control and try to adhere
# to the naming conventions detailed therein, eg. Subject, Role, Permission,
# Session, Subject Assignment, etc..
module Rbac
  def self.current_user; @@current_user ||= AnonymousUser.new; end
  def self.current_user= new; @@current_user = new; end

  def self.as subject, &block
    old = current_user
    self.current_user = subject
    yield
  ensure
    self.current_user = old
  end

  def self.to_identifier *things
    things.map do |thing|
      method = [:identifier, :to_param, :to_s].detect do |m|
        thing.respond_to? m
      end
      thing.send method
    end
  end

  module ActionController
    #def rbac_roles_controller options = {}
    #  raise ArgumentError, "You must define an array of operations providers with options[:operation_providers]" unless
    #    options[:operation_providers]

    #  include Rbac::RolesController
    #  self.operation_providers = options[:operation_providers]
    #  self.find_one_with = options[:find_one_with] if options[:find_one_with]
    #end
  end
end
ActionController::Base.send :extend, Rbac::ActionController
