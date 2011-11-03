class InterviewsController < ApplicationController
  # GET /interviews
  # GET /interviews.json
  before_filter :check_interview_schedule, :only => [:new]
  before_filter :load_candidate

  def index
#    @interviews = check_admin_or_hr(current_user.type) ? Interview.dummy : current_user.interviews
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
    @interview = Interview.find(params[:id])
  end

  # POST /interviews
  # POST /interviews.json
  def create
    @candidate = Candidate.find(params[:interview][:candidate_id])
    @interview = @candidate.interviews.new(params[:interview])

    respond_to do |format|
      if @interview.save
        format.html { redirect_to @interview, notice: 'Interview was successfully created.' }
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
    @interview.update_attributes(params[:interview])
    respond_to do |format|
       format.html { redirect_to root_path, notice: 'Interview was successfully updated.' }
       format.js { render :index }
       format.json { render json: @interview, status: :updated }
    end
  end

  def get_interviews
    @interviews = Interview.find(:all, :conditions => ["scheduled_at between '#{Time.at(params['start'].to_i).to_formatted_s(:db)}' and '#{Time.at(params['end'].to_i).to_formatted_s(:db)}'"] )
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
    @interview = Interview.find(params[:id])
    @interview.destroy

    render :index
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
