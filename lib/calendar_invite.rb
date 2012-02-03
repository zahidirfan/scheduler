require "icalendar"
module CalendarInvite
  include UserInfo

  def make_ical(interview)
    calendar = Icalendar::Calendar.new
    event = Icalendar::Event.new
    event.start = interview.scheduled_at.strftime("%Y%m%dT%H%M%S")
    event.end = interview.endtime.strftime("%Y%m%dT%H%M%S")
    event.summary = "Interview Scheduled for : #{interview.candidate.name}"
    event.description = "#{event.summary} \r\n Candidate Subject: #{interview.candidate.subject} \r\n Interview Scheduled at:#{interview.formated_scheduled_at} - #{interview.formated_schedule_endtime} \r\n "
    event.description << "Candidate Email: #{interview.candidate.email} \r\n" if interview.candidate.email
    event.description << "Candidate Phone: #{interview.candidate.phone} \r\n" if interview.candidate.phone
    event.description << "Candidate Mobile: #{interview.candidate.mobile} \r\n" if interview.candidate.mobile
    event.custom_property("DTSTART;TZID=GMT+5.30", event.start)
    event.custom_property("DTEND;TZID=GMT+5.30", event.end)
    event.custom_property("ORGANIZER;CN=#{current_user.name}:mailto", current_user.email)
    event.attendees = ["mailto:#{interview.user.email}, #{interview.print_interviewer_emailids}"]
    event.location = interview.interview_type
    calendar.add event
    calendar.publish
    file = File.open("/tmp/invite_#{interview.candidate.name}_#{interview.user.name}_#{interview.updated_at.to_i}.ics", "w+") { |f| f.write(calendar.to_ical); f.close }
  end
end
