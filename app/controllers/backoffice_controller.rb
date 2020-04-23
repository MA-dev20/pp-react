class BackofficeController < ApplicationController
  before_action :check_user
  before_action :set_company
  layout 'backoffice'
	
  def index
  end
	
  def companies
	@companies = Company.where(activated: true)
	@unactivated_companies = Company.where(activated: false)
	  
	@company = Company.find(params[:company_id]) if params[:company_id]
	@users = @company.users.order('fname') if @company
	@users.order('lname') if @users
	 
	@user = @company.users.find_by(id: params[:edit_user]) if params[:edit_user]
  end
  
  def catchwords
	CatchwordList.create(name: 'Peters Catchwords') if CatchwordList.find_by(name: 'Peters Catchwords').nil?
	@lists = @company.catchword_lists if @company
	@list = CatchwordList.find(params[:list_id]) if params[:list_id]
	@lists = CatchwordList.where(company_id: nil, game_id: nil) if !@lists
	@list = @lists.first if @lists.count != 0 && !@list
  end
  def objections
	ObjectionList.create(name: 'Peters Objections') if ObjectionList.find_by(name: 'Peters Objections').nil?
	@lists = @company.objection_lists if @company
	@list = ObjectionList.find(params[:list_id]) if params[:list_id]
	@lists = ObjectionList.where(company_id: nil, game_id: nil) if !@lists
	@list = @lists.first if @lists.count != 0 && !@list
  end
  def ratings
	RatingList.create(name: 'Peters Scores') if RatingList.find_by(name: 'Peters Scores').nil?
	@lists = @company.rating_lists if @company
	@list = RatingList.find(params[:list_id]) if params[:list_id]
	@lists = RatingList.where(company_id: nil) if !@lists
	@list = @lists.first if @lists.count != 0 && !@list
  end
	
  private
	def set_company
	  @company = Company.find(params[:company_id]) if params[:company_id]
	end
    def check_user
	  if user_signed_in?
		@root = current_user
		if @root.bo_role != 'root'
		  flash[:alert] = 'Dir fehlen die Berechtigungen für diese Seite!'
		  redirect_to dashboard_path
		end
	  else
		flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
		redirect_to root_path
	  end 
	end
end