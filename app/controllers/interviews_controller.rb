class InterviewsController < ApplicationController
  # GET /interviews
  # GET /interviews.json
<<<<<<< HEAD
  #before_filter :check_interview_schedule, :only => [:new]
  load_and_authorize_resource
  before_filter :load_candidate, :except => [:index]

  def index
    @interviews = current_user.type.to_s == "Interviewer" ? current_user.interviews : Interview.dummy
=======
  before_filter :check_interview_schedule, :only => [:new]
  before_filter :load_candidate

  def index
#    @interviews = check_admin_or_hr(current_user.type) ? Interview.dummy : current_user.interviews
>>>>>>> calendar
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interviews }
    end
  end

  # GET /interviews/1
  # GET /interviews/1.json
  def show
    @interview = Interview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interview }
    end
  end

  # GET /interviews/new
  # GET /interviews/new.json
  def new
    @interview = Interview.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview }
    end
  end

  # GET /interviews/1/edit
  def edit
    @interview = @candidate.interviews.find(params[:id])
  end

  # POST /interviews
  # POST /interviews.json
  def create
    @interview = @candidate.interviews.new(params[:interview])
    respond_to do |format|
      if @interview.save
        format.html { redirect_to candidate_path(@candidate), notice: 'Interview was successfully created.' }
        format.json { render json: @interview, status: :created, location: @interview }
      else
        format.html { render action: "new" }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /interviews/1
  # PUT /interviews/1.json
  def update
    @interview = Interview.find(params[:id])
    respond_to do |format|
      if @interview.update_attributes(params[:interview])
       format.html { redirect_to candidate_path(@candidate), notice: 'Interview was successfully updated.' }
       format.js { render :index }
       format.json { render json: @interview, status: :updated }
      else
        format.html { render action: "edit" }
        format.js { render :index }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_interviews
    @interviews = current_user.type.to_s == "Interviewer" ? current_user.interviews : Interview.dummy
    @interviews = Interview.fetch_interviews(params['start'], params['end'])
    interviews = []
    @interviews.each do |interview|
      interviews << {:id => interview.id, :candidate_id => interview.candidate_id, :title => "#{Candidate.find(interview.candidate_id).name}", :description => "<label>Assigned To:</label> #{User.find(interview.user_id).name} <br /> <label>Scheduled at:</label> #{interview.formated_scheduled_at}", :start => "#{interview.scheduled_at.iso8601}", :end => "#{interview.endtime.iso8601}", :allDay => false, :recurring => false }
    end
    render :text => interviews.to_json
  end

  def move
    @interview = Interview.find(params[:id])
    if @interview
      @interview.starttime = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@interview.starttime))
      @interview.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@interview.endtime))
#      @interview.all_day = params[:all_day]
      @interview.save
    end
  end


  def resize
    @event = Interview.find(params[:id])
    if @event
      @event.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@event.endtime))
      @event.save
    end
  end

  # DELETE /interviews/1
  # DELETE /interviews/1.json
  def destroy
    @interview = @candidate.interviews.find(params[:id])
    @interview.destroy

    respond_to do |format|
      format.html { redirect_to candidate_path(@candidate) }
      format.js { render :index }
      format.json { head :ok }
    end
  end

  protected

  def check_interview_schedule
    load_candidate
    unless @candidate.interviews.empty?
      i = @candidate.interviews.last
      if i.scheduled_at > Time.now.utc
        redirect_to edit_candidate_interview_path(@candidate, i)
      end
    end
  end
end
