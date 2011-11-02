module InterviewsHelper
  def feedback_link(interview)
    unless interview.comments.exists?
      link_to "Feedback", new_candidate_interview_comment_path(interview.candidate, interview)
    else
      link_to "Edit Feedback", edit_candidate_interview_comment_path(interview.candidate, interview, interview.comments.first)
    end
  end
end
