module LoginHelper
  def company_login(company)
    session[:company_id] = company.id
  end
  def current_company
    @current_company ||= Company.find_by(id: session[:company_id])
  end

  def company_logged_in?
    !current_company.nil?
  end

  def company_logout
    session.delete(:company_id)
    @current_company = nil
  end
end
