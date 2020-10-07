class ListController < ApplicationController
  before_action :set_user
  before_action :set_list, only: [:update, :add_entry, :add_sounds]

  def create
    @list = @company.lists.new(list_params)
    @list.user = @user
    if @list.name == ''
      render json: {no_title: true}
    else
      @list.save
      render json: {id: @list.id}
    end
  end

  def update
    @list.update(list_params)
    render json: {id: @list.id}
  end

  def destroy
    @list = List.find(params[:list_id])
    if @list.destroy
      render json: {success: true}
    else
      render json: {error: true}
    end
  end

  def add_entry
    @entry = @company.list_entries.find_by(name: entry_params[:name])
    @entry = @company.list_entries.create(entry_params) if !@entry
    @entry.update(user: @user) if @entry.user.nil?
    if !@list.list_entries.find_by(id: @entry.id)
      @list.list_entries << @entry
      if @entry.sound?
        render json: {id: @entry.id, name: @entry.name, sound: @entry.sound.url}
      else
        render json: {id: @entry.id, name: @entry.name}
      end
    else
      render json: {entry: "exists"}
    end
  end

  def add_sounds
    params[:list][:sounds].each do |sound|
      @entry = @company.list_entries.find_by(name: sound.original_filename.split('.mp3').first)
      if @entry
        @entry.update(sound: sound)
      else
        @entry = @company.list_entries.create(user: @user, name: sound.original_filename.split('.mp3').first, sound: sound)
      end
      @list.list_entries << @entry if !@list.list_entries.find_by(id: @entry.id)
    end
    render json: {id: @list.id}
    return
  end

  def edit_entry
    @entry = ListEntry.find_by(id: params[:entry])
    @entry.update(sound: params[:sound])
    if @entry.sound?
      render json: {id: @entry.id, sound: @entry.sound.url}
      return
    else
      render json: {id: @entry.id}
      return
    end
  end

  def delete_entry
    @entry = ListEntry.find_by(id: params[:entry_id])
    listCount = @entry.lists.where.not(id: params[:list_id]).count + @entry.catchword_lists.count + @entry.objection_lists.count + @entry.game_turns.count
    if listCount == 0
      @entry.destroy
    else
      ListEntryList.find_by(list_id: params[:list_id], entry: @entry).destroy
    end
    render json: {id: params[:entry_id]}
  end
  private
    def list_params
      params.require(:list).permit(:name, :content_folder_id)
    end
    def entry_params
      params.require(:list_entry).permit(:name, :sound)
    end

    def set_list
      @list = List.find(params[:list_id])
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
