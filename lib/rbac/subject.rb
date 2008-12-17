# Implements the Rbac required interface for Subject objects.
#
# This module defines stub methods, so you should redefine them in your mixin
# base *after* this is included, eg. with
#
#  has_and_belongs_to_many :roles
module Rbac::Subject
  def roles
    []
  end

  def has_role? *identifiers
    (Rbac.to_identifier(*roles) & identifiers).any?
  end

  def permissions
    roles.map(&:permissions).flatten
  end

  def has_permission? identifier, context=nil
    roles.any?{|r|r.has_permission?(identifier, context)}
  end
end
