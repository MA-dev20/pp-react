class ListController < ApplicationController
  before_action :set_user

  def create
    if params[:list][:type] == 'catchword'
      @list = @company.catchword_lists.new(list_params)
      @list.user = @user
      @list.save
      redirect_to dashboard_customize_path(catchword: @list.id)
      return
    else
      @list = @company.objection_lists.new(list_params)
      @list.user = @user
      @list.save
      redirect_to dashboard_customize_path(objection: @list.id)
      return
    end
  end
  private
    def list_params
      params.require(:list).permit(:name)
    end
    def set_user
      if user_signed_in? && company_logged_in?
        @user = current_user
        @company = current_company
      elsif user_signed_in?
        redirect_to dash_choose_company_path
      else
        redirect_to root_path
      end
    end
end
