class ListController < ApplicationController
  before_action :set_user
  before_action :set_list, only: [:update, :add_entry]

  def create
    if params[:list][:type] == 'catchword'
      @list = @company.catchword_lists.new(list_params)
      @list.user = @user
    else
      @list = @company.objection_lists.new(list_params)
      @list.user = @user
    end
    if @list.name == ''
      render json: {no_title: true}
    else
      @list.save
      render json: {id: @list.id}
    end
  end
  def update
    @list.update(list_params)
    render json: {id: @list.id, type: @list_type}
  end
  def destroy
    if params[:type] == 'catchword'
      @list = CatchwordList.find(params[:list_id])
    else
      @list = ObjectionList.find(params[:list_id])
    end
    if @list.destroy
      render json: {success: true}
    else
      render json: {error: true}
    end
  end

  def add_entry
    if @list_type == 'catchword'
      @entry = @user.catchwords.find_by(list_params)
      @entry = @company.catchwords.create(user: @user, name: params[:list][:name]) if !@entry
      @list.catchwords << @entry
    else
      @entry = @user.objections.find_by(list_params)
      @entry = @company.objections.create(user: @user, name: params[:list][:name]) if !@entry
      @list.objections << @entry
    end
    render json: {id: @entry.id, entry: @entry.name}
  end

  def edit_entry
    if params[:type] == 'catchword'
      @entry = Catchword.find_by(id: params[:entry])
      @entry.update(sound: params[:sound]);
    else
      @entry = Objection.find_by(id: params[:entry])
      @entry.update(sound: params[:sound]);
    end
    render json: {entry: @entry.id, type: params[:type]}
  end

  def delete_entry
    if params[:type] == 'catchword'
      @entry = Catchword.find_by(id: params[:entry_id])
    else
      @entry = Objection.find_by(id: params[:entry_id])
    end
    @entry.destroy
    render json: {success: true}
  end
  private
    def list_params
      params.require(:list).permit(:name, :content_folder_id)
    end
    def set_list
      if params[:list][:type] == 'catchword'
        @list = CatchwordList.find(params[:list_id])
        @list_type = 'catchword'
      else
        @list = ObjectionList.find(params[:list_id])
        @list_type = 'objection'
      end
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
