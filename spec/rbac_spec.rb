require File.dirname(__FILE__) + '/spec_helper'

describe Rbac do
  before :each do
    class Foo < ActiveRecord::Base
      self.stub!(:columns).and_return([ActiveRecord::ConnectionAdapters::Column.new("column", nil, "string", false)])
      include Rbac::Operation
    end
    Rbac.as(SuperUser.new){@operation = Foo.new}
  end

  describe "as anonymous user" do
    it_should_behave_like "does not have create access"
    it_should_behave_like "does not have read access"
    it_should_behave_like "does not have update access"
    it_should_behave_like "does not have destroy access"
  end

  describe "as super user" do
    before :each do
      sudo!
    end

    after :each do
      unsudo!
    end

    it_should_behave_like "has create access"
    it_should_behave_like "has read access"
    it_should_behave_like "has update access"
    it_should_behave_like "has destroy access"
  end

  describe ActionController do
    it "should extend action controller base" do
      ActionController::Base.respond_to?(:rbac_roles_controller).should be_true
    end

    describe "rbac_roles_controller method" do
      it "should allow a custom finder to be set through rbac_roles_controller options" do
        class TC < ActionController::Base
          rbac_roles_controller :operation_providers => [], :find_one_with => :jelly
        end
        TC.find_one_with.should == :jelly
      end

      it "should raise an error if operation_providers option is not passed" do
        lambda do
          class TC < ActionController::Base
            rbac_roles_controller
          end
        end.should raise_error(ArgumentError)
      end
    end
  end
end
