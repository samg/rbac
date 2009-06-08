class RbacSetup < ActiveRecord::Migration
  def self.up
    create_table "permissions" do |t|
      t.string   "provider"
      t.string   "operation"
      t.string   "rule"
      t.timestamps
    end

    create_table "permissions_roles", :id => false do |t|
      t.integer "permission_id"
      t.integer "role_id"
    end

    add_index "permissions_roles", ["permission_id"], :name => "index_permissions_roles_on_permission_id"
    add_index "permissions_roles", ["role_id"], :name => "index_permissions_roles_on_role_id"

    create_table "roles" do |t|
      t.string "name"
    end

    create_table "roles_users", :id => false do |t|
      t.integer "role_id"
      t.integer "user_id"
    end

    add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
    add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

    create_table "users", :force => true do |t|
      t.string   "login"
      t.string   "email"
      t.string   "crypted_password",          :limit => 40
      t.string   "salt",                      :limit => 40
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "remember_token"
      t.datetime "remember_token_expires_at"
      t.string   "prs_id"
      t.string   "first_name"
      t.string   "last_name"
    end
  end

  def self.down
  end
end

