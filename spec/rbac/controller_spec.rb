# This spec is for abstract, global stuff defined in ApplicationController
require File.dirname(__FILE__) + '/../spec_helper'

# Define TestController here so that the spec has access to nice thins like
# #controller
class TestController < ApplicationController; end

describe TestController, :type => :controller do
  describe "RBAC enforcement" do
    before :each do
      class TestModel < ActiveRecord::Base
        self.stub!(:columns).and_return([ActiveRecord::ConnectionAdapters::Column.new("column", nil, "string", false)])
        include Rbac::Operation

        define_rbac_rule :false, "this rule is always false" do
          false
        end
      end
      Rbac.as(SuperUser.new){@top = TestModel.new}
      stub_rbac_read @top

      class TestController
        def current_user; params[:sudo] ? SuperUser.new : nil; end
      end
    end
    def do_get params={}
      get :action, params.reverse_merge!(:sudo => false)
    end
    def do_action privileged=false; do_get :sudo => privileged; end

    describe "actions with model-level restrictions" do
      before :each do
        class TestController
          def action; TestModel.find :first; end
        end
      end

      it "should setup and teardown Rbac.current_user" do
        Rbac.should_receive(:current_user=).twice
        do_get
      end

      it_should_behave_like "a restricted controller"
    end

    describe "actions with controller-level restrictions" do
      before :each do
        class TestController
          include Rbac::Operation
          def action; end

          define_rbac_rule :false, "this rule is always false" do
            false
          end
        end
      end

      it_should_behave_like "a restricted controller"
    end
  end
end
