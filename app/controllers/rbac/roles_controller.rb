class Rbac::RolesController < ApplicationController
  cattr_accessor :operation_providers
  #self.operation_providers = [Admin::PermissionManagementController, Wd::Itucp, Answer]
  def index
    @roles = if ::Role.respond_to?(:paginate)
      ::Role.paginate :page => params[:page], :order => params[:order]
    else
      ::Role.find :all, :order => params[:order]
    end
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
      flash[:notice] = "::Role was successfully updated"
      redirect_to role_path(@role)
    else
      @operation_providers = operation_providers
      render :action => 'edit'
    end
  end

  def create
    @role = ::Role.new
    if @role.update_attributes(params[:role])
      flash[:notice] = "::Role was successfully created"
      redirect_to role_path(@role)
    else
      @operation_providers = operation_providers
      render :action => 'edit'
    end
  end

  def destroy
    @role = ::Role.find_by_name! params[:id]
    @role.destroy
    flash[:notice] = "::Role destroyed"
    redirect_to roles_path
  end
end
