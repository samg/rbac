# Helpers for giving tests unlimited permissions Always call unsudo! in the
# after_filter if you've enabled it or things might get screwy
class SuperRole
  include Rbac::Role
  def permissions; [Rbac::SimplePermission.new('*.*.*')]; end
end
class SuperUser
  include Rbac::Subject
  def roles; [SuperRole.new]; end
end

def sudo!
  Rbac.current_user = SuperUser.new
end

def unsudo!
  Rbac.current_user = nil
end

def stub_rbac_read operation
  operation.class.connection.stub!(:select_all).
    and_return([operation.attributes])
end

describe "a Rbac subject provider", :shared => true do
  describe "with basic roles" do
    before :each do
      @permission = stub 'permission', :identifier => 'provider.operation.*'
      @role = mock 'role', :identifier => 'role', :permissions => [@permission]
      @role.extend Rbac::Role
      @subject.stub!(:roles).and_return([@role])
    end

    it "should identify which roles it belongs to" do
      @subject.has_role?('role').should be_true
    end

    it "should identify which roles it doesn't belong to" do
      @subject.has_role?('another').should be_false
    end

    it "should identify which permissions it has" do
      @subject.has_permission?('provider.operation').should be_true
    end

    it "should identify which permissions it doesn't have" do
      @subject.has_permission?('provider.another').should be_false
    end
  end
end


describe "a Rbac role provider", :shared => true do
  it "should provide an identifier" do
    @role.identifier.should_not be_blank
  end

  describe "with basic permissions" do
    before :each do
      @permission = stub 'permission', :identifier => 'provider.operation.*'
      @role.stub!(:permissions).and_return([@permission])
    end

    it "should identify permissions it has" do
      @role.has_permission?('provider.operation').should be_true
    end

    it "should identify permissions it doesn't have" do
      @role.has_permission?('provider.another').should be_false
    end
  end
end

describe "has create access", :shared => true do
  it "should have create access" do
    @operation.stub!(:new_record?).and_return true
    lambda do
      @operation.save!
    end.should_not raise_error(Rbac::Operation::AuthorizationError)
  end
end

describe "does not have create access", :shared => true do
  it "should not have create access" do
    @operation.stub!(:new_record?).and_return true
    lambda do
      @operation.save!
    end.should raise_error(Rbac::Operation::AuthorizationError)
  end
end

describe "has read access", :shared => true do
  it "should have read access" do
    lambda do
      @operation.send(:callback, :after_initialize)
    end.should_not raise_error(Rbac::Operation::AuthorizationError)
  end
end

describe "does not have read access", :shared => true do
  it "should not have read access" do
    lambda do
      @operation.send(:callback, :after_initialize)
    end.should raise_error(Rbac::Operation::AuthorizationError)
  end
end

describe "has update access", :shared => true do
  it "should have update access" do
    @operation.stub!(:new_record?).and_return false
    lambda do
      @operation.save!
    end.should_not raise_error(Rbac::Operation::AuthorizationError)
  end
end

describe "does not have update access", :shared => true do
  it "should not have update access" do
    @operation.stub!(:new_record?).and_return false
    lambda do
      @operation.save!
    end.should raise_error(Rbac::Operation::AuthorizationError)
  end
end

describe "has destroy access", :shared => true do
  it "should have destroy access" do
    lambda do
      @operation.destroy
    end.should_not raise_error(Rbac::Operation::AuthorizationError)
  end
end

describe "does not have destroy access", :shared => true do
  it "should not have destroy access" do
    lambda do
      @operation.destroy
    end.should raise_error(Rbac::Operation::AuthorizationError)
  end
end

describe "a restricted controller", :shared => true do
  it "should be unauthorized with an unprivileged user" do
    do_action
    response.should be_unauthorized
  end

  it "should be successful with a privileged user" do
    do_action true
    response.should be_success
  end
end
