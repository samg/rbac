module Rbac::RolesHelper
  def permission_field provider, operation, rule = nil, options = {}
    rule_name, rule_description = rule_name(rule), rule_description(rule)
    conditional_str = (options[:negate] ? 'unless ' : 'if ' if rule).to_s
    pi = Rbac::Operation.permission_identifier(provider, operation, rule_name, options)
    name = "role[permissions][#{pi}]"
    id = "role_permissions_#{pi}"
    check_box_tag(name, 1, @role.permission_identifiers.include?(pi), :id => id) +
    content_tag(:label, ' ' + conditional_str  + rule_description, :for => id)
  end

  def permission_description identifier
    p, o, r = identifier.split('.')
    if r =~ /\A!/ then cs = 'unless' else cs = 'if' end
    cs = nil if r == "*"
    ri = r.split(/\A!/).last
    rule = rbac_rules_for(provider_from_string(p))[ri.intern]
    [
     "Permission to", content_tag(:b, operation_label(o)),
      content_tag(:b, provider_label(p)), cs, rule_description(rule) + '.'
    ].compact.join(' ').humanize
  rescue
    identifier
  end

  # accepts an rbac rule in this format
  # [:name, {:description => 'description'}]
  # assumes a static permission if rule is nil
  def rule_name rule
    if rule then rule.first else '*' end
  end

  def rule_description rule
    case rule
    when nil then "in any context"
    when Array then rule.last[:description]
    when Hash then rule[:description]
    else; raise ArgumentError, "Unknown rule type #{rule.inspect}" end
  end

  def operation_label operation
    operation = operation.to_s
    operation == '*' ? 'Perform Any Operation On' : operation.humanize
  end

  def provider_label provider
    case provider
    when '*' then "Any Object"
    when String then provider_label provider_from_string(provider)
    else; provider.label.pluralize end
  end

  def provider_from_string str
    return str if str == '*'
    str.classify.constantize
  end

  def operations_for provider
    if provider == '*'
      (@operation_providers || []).map(&method(:operations_for)).flatten.uniq 
    else
      provider.respond_to?(:operations) ? provider.operations : []
    end
  end

  def rbac_rules_for provider
    provider == '*' ? {} : provider.rbac_rules
  end

  def role_form_url(role)
    role.new_record? ? roles_path : role_path(role)
  end
end
