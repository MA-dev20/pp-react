class ShareController < ApplicationController
  before_action :set_user
  def share_content
    @user = User.find_by(email: params[:content][:email])
    @content = TaskMedium.find(params[:medium_id])
    if @user
      if !@user.company_users.find_by(company: @company)
        @user.companies << @company
      end
      @user.shared_content.create(task_medium: @content)
      render json: {success: 'Erfolgreich freigegen'}
    else
      @user = User.new(email: params[:content][:email])
      if @user.save(validate: false)
        @user.company_users.create(company: @company, role: 'user')
        if @admin.teams.count != 0
          @user.team_users.create(team: @admin.teams.first)
        end
        @user.shared_content.create(task_medium: @content)
        render json: {new_user: @user.id}
      else
        render json: {error: 'User nicht gefunden!'}
      end
    end
  end

  def update_user
    @user = User.find(params[:user_id])
    if @user.update(user_params)
      password = SecureRandom.urlsafe_base64(8)
    	@user.password = password
      if @user.save
        begin
  	      UserMailer.after_create(@user, password).deliver
  	    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
  	      flash[:alert] = 'Falsche Mail-Adresse? Konnte Mail nicht senden!'
  	    end
      end
    end
    render json: {user: @user}
  end

  def share_list
    @user = User.find_by(email: params[:list][:email])
    if params[:type] == 'catchword'
      @list = CatchwordList.find(params[:list_id])
    else
      @list = ObjectionList.find(params[:list_id])
    end
    if @user
      if !@user.company_users.find_by(company: @company)
        @user.companies << @company
      end
      @user.shared_content.create(catchword_list: @list) if params[:type] == 'catchword'
      @user.shared_content.create(objection_list: @list) if params[:type] == 'objection'
      render json: {success: 'Erfolgreich freigegen'}
      return
    else
      @user = User.new(email: params[:list][:email])
      if @user.save(validate: false)
        @user.company_users.create(company: @company, role: 'user')
        if @admin.teams.count != 0
          @user.team_users.create(team: @admin.teams.first)
        end
        @user.shared_content.create(catchword_list: @list) if params[:type] == 'catchword'
        @user.shared_content.create(objection_list: @list) if params[:type] == 'objection'
        render json: {new_user: @user.id}
        return
      else
        render json: {error: 'User nicht gefunden!'}
        return
      end
    end
  end

  def share_folder
    @user = User.find_by(email: params[:folder][:email])
    @folder = ContentFolder.find(params[:folder_id])
    if @user
      if !@user.company_users.find_by(company: @company)
        @user.companies << @company
      end
      @user.shared_folders.create(content_folder: @folder)
      render json: {success: 'Erfolgreich freigegen'}
      return
    else
      @user = User.new(email: params[:folder][:email])
      if @user.save(validate: false)
        @user.company_users.create(company: @company, role: 'user')
        if @admin.teams.count != 0
          @user.team_users.create(team: @admin.teams.first)
        end
        @user.shared_folders.create(content_folder: @folder)
        render json: {new_user: @user.id}
        return
      else
        render json: {error: 'User nicht gefunden!'}
        return
      end
    end
  end

  def share_pitch
    @user = User.find_by(email: params[:pitch][:email])
    @pitch = Pitch.find(params[:pitch_id])
    if @user
      if !@user.company_users.find_by(company: @company)
        @user.companies << @company
      end
      @user.shared_pitches.create(pitch: @pitch)
      render json: {success: 'Erfolgreich freigegen'}
      return
    else
      @user = User.new(email: params[:pitch][:email])
      if @user.save(validate: false)
        @user.company_users.create(company: @company, role: 'user')
        if @admin.teams.count != 0
          @user.team_users.create(team: @admin.teams.first)
        end
        @user.shared_pitches.create(pitch: @pitch)
        render json: {new_user: @user.id}
        return
      else
        render json: {error: 'User nicht gefunden!'}
        return
      end
    end
  end
  private
    def user_params
      params.require(:user).permit(:fname, :lname)
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
