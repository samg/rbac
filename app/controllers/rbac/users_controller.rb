class Rbac::UsersController < ApplicationController
  # GET /admin/users
  # GET /admin/users.xml
  def index
    @users = User.paginate :page => params[:page], :order => params[:order]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /admin/users/1
  # GET /admin/users/1.xml
  def show
    @user = params[:id] == 'current' ? current_user : User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
      format.json  { render :json => "#{@user.first_name} #{@user.last_name}"  }
    end
  end

  # GET /admin/users/new
  # GET /admin/users/new.xml
  def new
    @user = User.new
    @roles = Role.find :all

    respond_to do |format|
      format.html { render :action => 'edit'}
      format.xml  { render :xml => @user }
    end
  end

  # GET /admin/users/1/edit
  def edit
    @user = User.find(params[:id])
    @roles = Role.find :all
  end

  # POST /admin/users
  # POST /admin/users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(admin_user_path(@user)) }
        format.xml  { render :xml => @user, :status => :created, :location => admin_user_path(@user) }
      else
        format.html { render :action => "edit" }
        @roles = Role.find :all
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(admin_user_path(@user)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        @roles = Role.find :all
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end
end
