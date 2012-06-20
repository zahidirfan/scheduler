class InterviewsController < ApplicationController
  # GET /interviews
  # GET /interviews.json
  #before_filter :check_interview_schedule, :only => [:new]
  before_filter :authenticate
  load_and_authorize_resource
  before_filter :load_candidate, :except => [:index, :get_interviews, :export_interview, :move, :resize, :status_change_request]

  def index
    if (params[:view] != 'calendar')
      params[:interviewer_filter] ||=0
      if(params[:interviewer_filter].to_i > 0)
        interviews = Interview.by_user_id(params[:interviewer_filter])
      elsif !params[:interviewer_filter].nil? && params[:interviewer_filter].to_i == 0
        interviews = Interview.uncancelled
      else
        interviews = current_user.interviews.uncancelled
      end
      @interviews = case params[:view]
        when 'today'
          interviews.by_date(Date.today)
        when 'tomorrow'
          interviews.by_date(Date.tomorrow)
        when 'week'
          interviews.this_week
        when 'later'
          interviews.later
        when 'total'
          interviews.upcoming
        else
          interviews
      end
    end
    @interview = Interview.new
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
    params[:interviewer_filter] ||= @interview.user_id
    @other_interviewers = @interview.interviewers
  end

  # POST /interviews
  # POST /interviews.json
  def create
    params[:interview][:scheduler_id] = current_user.id
    @interview = @candidate.interviews.new(params[:interview])
    params[:other_interviewers].split(",").each do |interviewer|
      @interview.interviewers.new({:user_id => interviewer})
    end
    respond_to do |format|
      if @interview.save
        format.html { redirect_to candidate_path(@candidate), notice: 'Interview was successfully created.' }
        format.js { render :index }
        format.json { render json: @interview, status: :created, location: @interview }
      else
        format.html { render action: "new" }
        format.js { render :index }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /interviews/1
  # PUT /interviews/1.json
  def update
    params[:interview][:scheduler_id] = current_user.id
    @interview = @candidate.interviews.find(params[:id])
    params[:interview][:scheduled_at] = params[:edit][:date_scheduled_at]
    @interview.interviewers.create!(convert_string_to_hash(params[:interviewer_id], :user_id)) unless params[:interviewer_id].blank?
    @interview.interviewers.destroy(*params[:mark_to_delete].split(',').uniq) unless params[:mark_to_delete].blank?

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
    if params[:interviewer_id].to_i > 0
      meth = Interview.by_user_id(params[:interviewer_id])
    elsif(!params[:interviewer_id].nil? && params[:interviewer_id].to_i == 0)
      meth = Interview.uncancelled
    else
      meth = current_user.interviews.uncancelled
    end
    interviews = meth.fetch_interviews(params['start'], params['end'])
    desc_interviews = interviews.collect do |interview|
      {:id => interview.id, :candidate_id => interview.candidate_id, :interviewer_id => interview.user_id, :title => "#{interview.candidate.name}", :description => "<label>Assigned To:</label> #{interview.user.name} <br /> <label>Scheduled at:</label> #{interview.formated_scheduled_at}", :start => "#{interview.scheduled_at.iso8601}", :end => "#{interview.endtime.iso8601}", :user_type => "#{current_user.role}", :other_int => "#{interview.other_interviewers.to_json}", :comment_id => "#{interview.comments.exists? ? interview.comments.first.id : 0 }", :allDay => false, :recurring => false }
    end
    render :text => desc_interviews.to_json
  end

  def move
    @interview = Interview.find(params[:id])
    if @interview
      @interview.scheduled_at = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@interview.scheduled_at))
      @interview.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@interview.endtime))
      @interview.scheduler_id = current_user.id
      #      @interview.all_day = params[:all_day]
      @interview.save
    end
    respond_to do |format|
      format.js { render :index }
    end
  end


  def resize
    @interview = Interview.find(params[:id])
    if @interview
      endtime = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@interview.endtime))
      @interview.update_attribute(:endtime, endtime)
    end
    respond_to do |format|
      format.js { render :index }
    end
  end

  # DELETE /interviews/1
  # DELETE /interviews/1.json
  def destroy
    @interview = @candidate.interviews.find(params[:id])
    if params["cancel"]
      if @interview.comments.length > 0
        @interview.comments.first.update_attributes(:candidate_id => @candidate.id, :user_id => current_user.id, :status => 'Cancelled')
      else
        @interview.comments.create!(:candidate_id => @candidate.id, :user_id => current_user.id, :description => "Due to some reasons, interview is cancelled.", :status => 'Cancelled')
      end
    else
      @interview.destroy
    end
    @candidate.update_attributes(:status => nil)

    respond_to do |format|
      format.html { redirect_to candidate_path(@candidate) }
      format.js { render :index }
      format.json { head :ok }
    end
  end

  def status_change_request 
    Request.create(:status => params[:status], :interview_id => params[:id], :user_id => current_user.id)
    redirect_to interviews_path
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
