module Rbac::RolesController
  def self.included base
    base.class_eval do
      cattr_accessor :operation_providers
      cattr_accessor :find_one_with
      self.find_one_with ||= :find

      # GET /admin/roles
      def index
        @roles = ::Role.paginate :page => params[:page], :order => params[:order]
      rescue
        @roles = ::Role.find :all, :order => params[:order]
      end

      def show
        @role = ::Role.send find_one_with, params[:id]
      end

      def new
        @role = ::Role.new
        @operation_providers = operation_providers
        render :action => :edit
      end

      def edit
        @role = ::Role.send find_one_with, params[:id]
        @operation_providers = operation_providers
      end

      def update
        @role = ::Role.send find_one_with, params[:id]
        if @role.update_attributes(params[:role])
          flash[:notice] = "Role was successfully updated"
          redirect_to admin_role_path(@role)
        else
          @operation_providers = operation_providers
          render :action => 'edit'
        end
      end

      def create
        @role = ::Role.new
        if @role.update_attributes(params[:role])
          flash[:notice] = "Role was successfully created"
          redirect_to admin_role_path(@role)
        else
          @operation_providers = operation_providers
          render :action => 'edit'
        end
      end

      def destroy
        @role = ::Role.send find_one_with, params[:id]
        @role.destroy
        flash[:notice] = "Role destroyed"
        redirect_to admin_roles_path
      end
    end
  end
end
