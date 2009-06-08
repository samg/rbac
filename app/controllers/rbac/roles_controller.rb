class Rbac::RolesController < ApplicationController
  private
  def self.operation_providers
    Rbac::operation_providers
  end

  def operation_providers
    self.class.operation_providers
  end

  public
  def index
    @roles = ::Role.paginate :page => params[:page], :order => params[:order]
  rescue
    @roles = ::Role.find :all, :order => params[:order]
  end

  def show
    @role = ::Role.find_by_name! params[:id]
  end

  def new
    @role = ::Role.new
    @operation_providers = operation_providers
    render :action => :edit
  end

  def edit
    @role = ::Role.find_by_name! params[:id]
    @operation_providers = operation_providers
  end

  def update
    @role = ::Role.find_by_name! params[:id]
    if @role.update_attributes(params[:role])
      flash[:notice] = "Role was successfully updated"
      redirect_to role_path(@role)
    else
      @operation_providers = operation_providers
      render :action => 'edit'
    end
  end

  def create
    @role = ::Role.new
    if @role.update_attributes(params[:role])
      flash[:notice] = "Role was successfully created"
      redirect_to role_path(@role)
    else
      @operation_providers = operation_providers
      render :action => 'edit'
    end
  end

  def destroy
    @role = ::Role.find_by_name! params[:id]
    @role.destroy
    flash[:notice] = "Role destroyed"
    redirect_to roles_path
  end
end
