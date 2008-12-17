# Implements the Rbac required interface for Role objects
#
# This module defines stub methods, so you should redefine them in your mixin
# base *after* this is included, eg. with
#
#  has_and_belongs_to_many :users
#  has_and_belongs_to_many :permissions
module Rbac::Role
  def identifier
    to_param
  end

  def permissions
    []
  end

  def permission_identifiers
    permissions.map(&:identifier)
  end

  def has_permission? operation_identifier, context=nil
    target = context ? context : Rbac::Operation::Enforcer
    target.ok_permissions(operation_identifier, *permissions.map(&:identifier)).any?
  end
end
