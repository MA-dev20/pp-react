class ContentFolderController < ApplicationController
  before_action :set_folder

  def update
    @folder.update(folder_params)
    render json: {id: @folder.id, name: @folder.name}
  end
  def delete
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
      params.require(:content_folder).permit(:name)
    end
    def set_folder
      @folder = ContentFolder.find(params[:folder_id])
    end
end
