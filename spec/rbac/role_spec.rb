require File.dirname(__FILE__) + '/../spec_helper'
describe Role do
  before :each do
    class TestRole; include Rbac::Role; end
    @role = TestRole.new
  end

  it "should stub permissions" do
    @role.permissions.should == []
  end

  it "should provide a permission_identifiers convenience method" do
    @role.stub!(:permissions).and_return [mock(Permission, :identifier => 'a.b.c')]
    @role.permission_identifiers.should == ['a.b.c']
  end
end
