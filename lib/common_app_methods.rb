module CommonAppMethods
    def user_roles_hash
    {"Business Manager" => "Bm", "Human Resource" => "Hr", "Interviewer" => "Interviewer", "Project Lead" => "Pl", "Administrator" => "Administrator"}
  end

  def feedback_status_hash
    {"Clear" => "Clear", "Hold" => "Hold", "Drop" => "Drop"}
  end

  def check_admin_or_hr(t)
    return ["Administrator", "Hr"].include?(t) ? true : false
  end
end
