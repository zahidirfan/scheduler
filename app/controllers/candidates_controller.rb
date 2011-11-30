class CandidatesController < ApplicationController
  # GET /candidates
  # GET /candidates.json
  before_filter :authenticate, :except => [:new, :create, :pull_tags]
  load_and_authorize_resource
  skip_authorize_resource :only => [:new, :create, :pull_tags, :fetch_candidates]

  def index
    if params[:search]
    @candidates = Candidate.tagged_with(params[:search], :any => true).paginate(:page => params[:page], :per_page => "10")
    search_params = params[:search].split(',')
    @search_tags = ActsAsTaggableOn::Tag.named_like_any(search_params)
    @title = "tagged with #{search_params.join(', ')}"

    elsif !params[:status].blank?
    @candidates = Candidate.paginate(:page => params[:page], :per_page => "10").find_all_by_status(params[:status])
    else
    @candidates = Candidate.active.order("name").paginate(:page => params[:page], :per_page => "10")
    end
    @tags = Candidate.tag_counts_on(:tags)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidates }
    end
  end

  def tag
    if request.delete?
      Candidate.tagged_with(params[:name]).each { |c| c.tag_list.remove(params[:name]) }
      ActsAsTaggableOn::Tag.delete(params[:id])
      flash.now.notice = "Tag Name and its associated taggings are sucessfully deleted."
    else
      @candidates = Candidate.tagged_with(params[:name]).paginate(:page => params[:page], :per_page => "10")
      @title = "tagged with #{params[:name]}"
      @tags = Candidate.tag_counts_on(:tags)
      render :action => 'index'
    end
  end


  # GET /candidates/1
  # GET /candidates/1.json
  def show
    @candidate = Candidate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate }
    end
  end

  # GET /candidates/new
  # GET /candidates/new.json
  def new
    @candidate = Candidate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate }
    end
  end

  def new_from_career_form
    @candidate = Candidate.new
  end

  # GET /candidates/1/edit
  def edit
    @candidate = Candidate.find(params[:id])
  end

  # POST /candidates
  # POST /candidates.json
  def create
    @candidate = Candidate.new(params[:candidate])

    respond_to do |format|
      if @candidate.save
        unless current_user.blank?
          format.html { redirect_to @candidate, notice: 'Candidate was successfully created.' }
          format.json { render json: @candidate, status: :created, location: @candidate }
        else
          format.html { redirect_to add_candidate_path, notice: 'Candidate was successfully created.' }
          format.json { render json: add_path, status: :created }
        end
      else
        format.html { render action: "new" }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /candidates/1
  # PUT /candidates/1.json
  def update
    @candidate = Candidate.find(params[:id])

    respond_to do |format|
      if @candidate.update_attributes(params[:candidate])
        format.html { redirect_to @candidate, notice: 'Candidate was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /candidates/1
  # DELETE /candidates/1.json
  def destroy
    @candidate = Candidate.find(params[:id])
    @candidate.destroy

    respond_to do |format|
      format.html { redirect_to candidates_url }
      format.json { head :ok }
    end
  end

  def mark_archive
    @candidate = Candidate.find(params[:candidate_id])
    @candidate.update_attribute(:archive, true)
    redirect_to candidates_url
  end

  def fetch_candidates
    if params[:q]
    like= "%".concat(params[:q].concat("%"))
    candidates = Candidate.where("name like ?", like).order("name")
    else
    candidates = Candidate.all.order("name")
    end
    list = candidates.map {|c| Hash[ id: c.id, name: c.name, subject: (c.subject ? c.subject : "")]}
    render json: list
  end

  def mark_archive_for_selected_candidates
    candidates = Candidate.find_all_by_id(params[:select].values) unless params[:select].blank?
    unless candidates.blank?
      candidates.each do |candidate|
        candidate.update_attribute(:status, params[:change_status])
      end
    redirect_to candidates_url, :notice => 'Status was successfully updated.'
    else
    redirect_to candidates_url, :notice => 'No candidates selected for update.'
    end
  end

  def create_custom_tags
    tag_name = params[:name]
    if tag_name
      @tag = ActsAsTaggableOn::Tag.create(:name => tag_name.downcase)
      flash.now.notice = "Custom Tag Created Successfully"
    end
    @tag_list = ActsAsTaggableOn::Tag.all
  end

  def pull_tags
    render json: ActsAsTaggableOn::Tag.where("name LIKE ?", "%#{params[:q]}%")
  end

end
