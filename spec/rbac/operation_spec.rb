require File.dirname(__FILE__) + '/../spec_helper'

class Operator < ActiveRecord::Base
  include Rbac::Operation
end

class OperatorController < ActionController::Base
  include Rbac::Operation
  def action1; end
  def action2; end
end

describe Rbac::Operation do
  before :each do
    class Foo < ActiveRecord::Base
      self.stub!(:columns).and_return([ActiveRecord::ConnectionAdapters::Column.new("column", nil, "string", false)])
      include Rbac::Operation
      define_rbac_rule :false, "always false" do
        false
      end
    end
    Rbac.as(SuperUser.new){@operation = Foo.new}
  end
  it 'should know its operations if it descends from ActiveRecord::Base' do
    Operator.operations.should == [:create, :read, :update, :destroy]
  end

  it 'should stub out a label method' do
    Operator.label.should == 'Operator'
  end

  it 'should know its operations if it descends from ActionController::Base' do
    pending
    OperatorController.operations.should == Set[:action1, :action2]
  end

  describe "operation_identifier" do
    it "should create a valid identifier from a class and operation" do
      Rbac::Operation.operation_identifier(Operator, :create).
        should == 'operator.create'
    end
  end

  describe 'permission_identifier' do
    it "should create a valid identifier from a class, operation and rule" do
      Rbac::Operation.permission_identifier(Operator, :create, :submitted?).
        should == 'operator.create.submitted?'
    end

    it "should accept a :negate option" do
      Rbac::Operation.permission_identifier(Operator, :create, :submitted?, :negate => true).
        should == 'operator.create.!submitted?'
    end
  end
  describe "rbac_rules" do
    it "should allow access to rbac rules" do
      lambda do
        @operation.enforcer.false
      end.should_not raise_error
    end

    it "should return an empty hash instead of nil if no rbac rules are defined" do
      class TestRulesClass; include Rbac::Operation; end
      TestRulesClass.rbac_rules.should == {}
      TestRulesClass.new.rbac_rules.should == {}
    end

    describe Rbac::Operation::Enforcer do
      it "should do a literal match on provider and operation" do
        Rbac::Operation::Enforcer.ok_permissions('foo.create', 'foo.create.*', 'bad.create.*').
          should == ['foo.create.*']
      end

      it "should do a wildcard match on provider" do
        Rbac::Operation::Enforcer.ok_permissions('foo.create', '*.create.*', 'bad.create.*').
          should == ['*.create.*']
      end

      it "should do a wildcard match on operation" do
        Rbac::Operation::Enforcer.ok_permissions('foo.create', 'foo.*.*', 'bad.create.*').
          should == ['foo.*.*']
      end

      it "should do an inheritance match on provider" do
        Rbac::Operation::Enforcer.ok_permissions('foo.create', 'active_record/base.create.*', 'bad.create.*').
          should == ['active_record/base.create.*']
      end
    end
  end
end
