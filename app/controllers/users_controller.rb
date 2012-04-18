class UsersController < ApplicationController

  before_filter :authenticate, :except => [:new, :create]
  load_and_authorize_resource
  #before_filter :authenticate_admin
  # GET /users
  # GET /users.json
  def index
    @users = User.page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @interviews = @user.comments.order("updated_at DESC").limit(5)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  def password_change
    if request.put?
      @user = current_user
      if @user.update_attributes(params[:user]) && (not params[:user][:password].blank?)
        redirect_to :root, :notice => 'Password changed successfully.'
      elsif params[:user][:password].blank?
        redirect_to password_change_path, :notice => 'Password should not be blank.'
      end
    end
  end

  def fetch_users
    if params[:q]
    like_name = "%".concat(params[:q].concat("%"))
    users = User.where("id != ? and name like ?", params[:assgined_id].to_i, like_name).order("name")
    else
    users = User.all.order("name")
    users.delete_if {|x| x.id == params[:assigned_id]}
    end
    list = users.map {|u| Hash[ id: u.id, name: u.name, subject: u.role]}
    render json: list
  end

end
