require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")
require File.expand_path(File.dirname(__FILE__) + "/lib/rake_commands.rb")

class RbacGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.migration_template "migrations/rbac_setup.rb",
                           'db/migrate',
                           :migration_file_name => "rbac_setup"
      m.readme 'README'
    end
  end

  private

end
