class ShareController < ApplicationController
  before_action :set_user
  def share_content
    @content = TaskMedium.find(params[:medium_id])
    if params[:content][:email] != ''
      @new_users = []
      params[:content][:email].split(' ').each do |email|
        @user = User.find_by(email: email)
        if @user
          if !@user.company_users.find_by(company: @company)
            @user.companies << @company
          end
          @user.shared_content.create(task_medium: @content)
        else
          @user = User.new(email: email)
          @user.save(validate: false)
          @user.company_users.create(company: @company, role: 'user')
          @user.shared_content.create(task_medium: @content)
          @new_users << @user
        end
      end
    elsif params[:content][:available_for]
      @content.update(content_params)
    else
      render json: {error: 'Fehler beim teilen!'}
      return
    end
    if @new_users
      render json: {new_users: @new_users}
    else
      render json: {success: 'Inhalt erfolgreich geteilt'}
    end
  end

  def share_pdf
    @pdf = TaskPdf.find(params[:pdf_id])
    if params[:content][:email] != ''
      @new_users = []
      params[:content][:email].split(' ').each do |email|
        @user = User.find_by(email: email)
        if @user
          if !@user.company_users.find_by(company: @company)
            @user.companies << @company
          end
          @user.shared_content.create(task_pdf: @pdf)
        else
          @user = User.new(email: email)
          @user.save(validate: false)
          @user.company_users.create(company: @company, role: 'user')
          @user.shared_content.create(task_pdf: @pdf)
          @new_users << @user
        end
      end
    elsif params[:content][:available_for]
      @pdf.update(content_params)
    else
      render json: {error: 'Fehler beim teilen!'}
      return
    end
    if @new_users
      render json: {new_users: @new_users}
    else
      render json: {success: 'PDF erfolgreich geteilt'}
    end
  end

  def update_user
    params[:users].each do |u|
      @user = User.find_by(id: u[0])
      if u[1]["fname"] != '' && u[1]["lname"] != ''
        password = SecureRandom.urlsafe_base64(8)
        @user.update(fname: u[1]["fname"], lname: u[1]["lname"], password: password)
        begin
    	  UserMailer.after_create(@user, password).deliver
    	  rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
    	    flash[:alert] = 'Falsche Mail-Adresse? Konnte Mail nicht senden!'
    	  end
      else
        @user.destroy
      end
    end
    render json: {success: 'User gespeichert'}
  end

  def share_list
    if params[:type] == 'catchword'
      @list = CatchwordList.find(params[:list_id])
    else
      @list = ObjectionList.find(params[:list_id])
    end
    if params[:list][:email] != ''
      @new_users = []
      params[:list][:email].split(' ').each do |email|
        @user = User.find_by(email: email)
        if @user
          if !@user.company_users.find_by(company: @company)
            @user.companies << @company
          end
          @user.shared_content.create(catchword_list: @list) if params[:type] == 'catchword'
          @user.shared_content.create(objection_list: @list) if params[:type] == 'objection'
        else
          @user = User.new(email: email)
          @user.save(validate: false)
          @user.company_users.create(company: @company, role: 'user')
          @user.shared_content.create(catchword_list: @list) if params[:type] == 'catchword'
          @user.shared_content.create(objection_list: @list) if params[:type] == 'objection'
          @new_users << @user
        end
      end
    elsif params[:list][:available_for]
      @list.update(list_params)
    else
      render json: {error: 'Fehler beim teilen!'}
      return
    end
    if @new_users
      render json: {new_users: @new_users}
    else
      render json: {success: 'Content erfolgreich geteilt'}
    end
  end

  def share_folder
    @folder = ContentFolder.find(params[:folder_id])
    if params[:folder][:email] != ''
      @new_users = []
      params[:folder][:email].split(' ').each do |email|
        @user = User.find_by(email: email)
        if @user
          if !@user.company_users.find_by(company: @company)
            @user.companies << @company
          end
          @user.shared_folders.create(content_folder: @folder)
        else
          @user = User.new(email: email)
          @user.save(validate: false)
          @user.company_users.create(company: @company, role: 'user')
          @user.shared_folders.create(content_folder: @folder)
          @new_users << @user
        end
      end
    elsif params[:folder][:available_for]
      @folder.update(folder_params)
    else
      render json: {error: 'Fehler beim teilen!'}
      return
    end
    if @new_users
      render json: {new_users: @new_users}
    else
      render json: {success: 'Content erfolgreich geteilt'}
    end
  end

  def share_pitch
    @pitch = Pitch.find(params[:pitch_id])
    if params[:pitch][:email] != ''
      @new_users = []
      params[:pitch][:email].split(' ').each do |email|
        @user = User.find_by(email: email)
        if @user
          if !@user.company_users.find_by(company: @company)
            @user.companies << @company
          end
          @user.shared_pitches.create(pitch: @pitch)
        else
          @user = User.new(email: email)
          @user.save(validate: false)
          @user.company_users.create(company: @company, role: 'user')
          @user.shared_pitches.create(pitch: @pitch)
          @new_users << @user
        end
      end
    elsif params[:pitch][:available_for]
      @pitch.update(pitch_params)
    else
      render json: {error: 'Fehler beim teilen!'}
      return
    end
    if @new_users && @new_users.length != 0
      render json: {new_users: @new_users}
    else
      render json: {success: 'Content erfolgreich geteilt'}
    end
  end

  def release_pitch_video
    @video = PitchVideo.find(params[:video_id])
    if @video.released
      @video.update(released: false)
      flash[:info] = 'Video Freigabe aufgehoben!'
    else
      @video.update(released: true)
      flash[:info] = 'Video freigegeben!'
    end
    redirect_to dashboard_pitch_video_path(@video.game_turn)
  end
  private
    def user_params
      params.require(:user).permit(:fname, :lname)
    end
    def folder_params
      params.require(:folder).permit(:available_for, :department_id, :team_id)
    end
    def content_params
      params.require(:content).permit(:available_for, :department_id, :team_id)
    end
    def list_params
      params.require(:list).permit(:available_for, :department_id, :team_id)
    end
    def pitch_params
      params.require(:pitch).permit(:available_for, :department_id, :team_id)
    end
    def set_user
      if user_signed_in? && company_logged_in?
        @admin = current_user
        @company = current_company
      elsif user_signed_in?
        redirect_to dash_choose_company_path
      else
        redirect_to root_path
      end
    end
end
