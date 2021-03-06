class CommentsController < ApplicationController
  before_filter :load_candidate
  # GET /comments
  # GET /comments.json
  def index
    @interview = Interview.find(params[:interview_id])
    @comments = @interview.comments

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = current_user.comments.new
    @interview = Interview.find(params[:interview_id])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = current_user.comments.new(params[:comment])
    @comment.status_value = FEEDBACK_STATUS.key(@comment.status)
    respond_to do |format|
      if @comment.save
        format.html { redirect_to interviews_path, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created, location: @comment }
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])
    params[:comment][:status_value] = FEEDBACK_STATUS.key(params[:comment][:status])
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to interviews_path, notice: 'Comment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to interviews_path }
      format.json { head :ok }
    end
  end
end
