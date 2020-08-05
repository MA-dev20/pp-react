class ContentFolderController < ApplicationController
  before_action :set_folder, only: [:update, :delete]
  before_action :set_user
  before_action :set_company

  def new
    authorize! :create, ContentFolder
    @folder = @user.content_folders.new(folder_params)
    @folder.company = @company
    @folder.save
    render json: {id: @folder.id, name: @folder.name, content_folder_id: @folder.content_folder_id}
  end

  def update
    authorize! :update, @folder
    @folder.update(folder_params)
    render json: {id: @folder.id, name: @folder.name}
  end
  def delete
    authorize! :destroy, @folder
    @folder_id = @folder.id
    begin
      @folder.destroy
    rescue ActiveRecord::InvalidForeignKey
      render json: {error: 'Es gibt noch Content der einer Task zugeordnet ist im Folder Tree!'}
      return
    end
    render json: {id: @folder_id}
    return
  end

  private
    def folder_params
      params.require(:content_folder).permit(:name, :content_folder_id)
    end
    def set_user
      if user_signed_in?
  	    @user = current_user
  	  else
  	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
  	    redirect_to root_path
  	  end
    end
    def set_company
      if company_logged_in?
        @company = current_company
      else
        redirect_to dash_choose_company_path
      end
    end
    def set_folder
      @folder = ContentFolder.find(params[:folder_id])
    end
end
