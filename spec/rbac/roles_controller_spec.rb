require File.dirname(__FILE__) + '/../spec_helper'

class TestRolesController < ActionController::Base
  rbac_roles_controller :operation_providers => ['providers']
  around_filter :rbac_as
  def rbac_as
    Rbac.as(params[:sudo] ? SuperUser.new : nil){yield}
  rescue Rbac::Operation::AuthorizationError
    render(:nothing => true, :layout => false, :status => 401)
  end
end
ActionController::Routing::Routes.draw do |map|
  map.connect 'test/:action/:id', :controller => 'test_roles'
end

describe TestRolesController, :type => :controller do
  before :all do
    class Role < ActiveRecord::Base
      stub!(:columns).and_return([])
      include Rbac::Role
    end
  end

  it "should have a operations providers attribute" do
    TestRolesController.operation_providers.should == ['providers']
  end

  describe "a custom finder can be specified", :shared => true do
    it "should allow a custom find method to be used" do
      begin
        TestRolesController.find_one_with = :find_by_name
        Role.should_receive(:find_by_name).and_return stub("Role", :null_object => true)
        do_action
      # teardown
      ensure
        TestRolesController.find_one_with = :find
      end
    end
  end

  describe "index" do
    describe "with out will_paginate installed" do
      before :each do
        @roles = [mock_model(Role)] * 2
      end
      it "should fall back to find if paginate fails" do
        Role.stub!(:paginate).and_raise NoMethodError
        Role.should_receive(:find).and_return @roles
        get :index
        assigns(:roles).should be(@roles)
      end
    end
    describe "with will_paginate installed" do
      before :each do
        @roles = [mock_model(Role)] * 2
        Role.stub!(:paginate).and_return @roles
      end

      def do_get
        get :index
      end
      alias_method :do_action, :do_get

      it "should assign roles" do
        do_get
        assigns(:roles).should be(@roles)
      end

      it "should render index" do
        do_get
        response.should render_template('index')
      end
    end
  end

  describe "show" do
    before :each do
      @role = mock_model Role
      Role.stub!(:find).with('name').and_return @role
    end

    it_should_behave_like "a custom finder can be specified"

    def do_get(params = {})
      get :show, {:id => "name"}.merge(params)
    end
    alias_method :do_action, :do_get

    it "should assign role" do
      do_get
      assigns(:role).should be(@role)
    end

    it "should render show" do
      do_get
      response.should render_template('show')
    end

  end

  describe "edit" do
    before :each do
      @role = mock_model Role
      Role.stub!(:find).with('name').and_return @role
    end

    def do_get(params = {})
      get :edit, {:id => "name"}.merge(params)
    end
    alias_method :do_action, :do_get

    it_should_behave_like "a custom finder can be specified"

    it "should assign role" do
      do_get
      assigns(:role).should be(@role)
    end

    it "should assign an array of operation providers" do
      do_get
      assigns(:operation_providers).should == controller.send(:operation_providers)
    end

    it "should render edit" do
      do_get
      response.should render_template('edit')
    end
  end

  describe "new" do
    before :each do
      @role = mock_model Role
      Role.stub!(:new).and_return @role
    end

    def do_get(params = {})
      get :new, {}.merge(params)
    end
    alias_method :do_action, :do_get

    it "should assign role" do
      do_get
      assigns(:role).should be(@role)
    end

    it "should assign an array of operation providers" do
      do_get
      assigns(:operation_providers).should == controller.send(:operation_providers)
    end

    it "should render edit" do
      do_get
      response.should render_template('edit')
    end
  end


  describe "update" do
    before :each do
      @role = mock_model Role, :to_param => 'name'
      Role.stub!(:find).with('name').and_return @role
    end

    it_should_behave_like "a custom finder can be specified"

    def do_put(params = {})
      put :update, {:id => 'name', :role => "role_attributes"}.merge(params)
    end
    alias_method :do_action, :do_put

    describe "with successful save" do
      before(:each) do
        @role.should_receive(:update_attributes).with("role_attributes").
          and_return true
      end

      it "should redirect edit" do
        do_put
        response.should redirect_to(:action => 'edit')
      end
    end

    describe "with unsuccessful save" do
      before(:each) do
        @role.should_receive(:update_attributes).with("role_attributes").
          and_return false
      end

      it "should render edit" do
        do_put
        response.should render_template('edit')
      end

      it "should assign an array of operation providers" do
        do_put
        assigns(:operation_providers).should == controller.send(:operation_providers)
      end
    end
  end

  describe "create" do
    before :each do
      @role = mock_model Role, :to_param => 'name'
      Role.stub!(:new).and_return @role
    end

    def do_post(params = {})
      post :create, {:role => "role_attributes"}.merge(params)
    end
    alias_method :do_action, :do_post

    describe "with successful save" do
      before(:each) do
        @role.should_receive(:update_attributes).with("role_attributes").
          and_return true
      end

      it "should redirect edit" do
        do_post
        response.should redirect_to(admin_role_url(@role))
      end
    end

    describe "with unsuccessful save" do
      before(:each) do
        @role.should_receive(:update_attributes).with("role_attributes").
          and_return false
      end

      it "should render edit" do
        do_post
        response.should render_template('edit')
      end

      it "should assign an array of operation providers" do
        do_post
        assigns(:operation_providers).should == controller.send(:operation_providers)
      end
    end
  end

  describe "destroy" do
    before :each do
      @role = mock_model Role, :to_param => 'name'
      Role.stub!(:find).with('name').and_return @role
    end

    def do_delete
      delete :destroy, :id => 'name'
    end
    alias_method :do_action, :do_delete

    it_should_behave_like "a custom finder can be specified"

    it "should destroy the record" do
      @role.should_receive(:destroy)
      do_delete
    end

    it "should redirect to index" do
      @role.stub!(:destroy)
      do_delete
      response.should redirect_to(admin_roles_path)
    end
  end
end
