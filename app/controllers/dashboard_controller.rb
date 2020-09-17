class DashboardController < ApplicationController
  before_action :set_user
  before_action :set_company, except: [:choose_company]
  before_action :check_inactive, except: [:choose_company]
  layout "dashboard"

  def content
    @peters_count = ContentFolder.select{|cf| cf.available_for == 'global'}.size + TaskMedium.select{|tm| tm.available_for == 'global' && tm.is_pdf != true}.size + CatchwordList.select{|cl| cl.available_for == 'global' && cl.name != 'task_list'}.size + ObjectionList.select{|ol| ol.available_for == 'global' && ol.name != 'task_list'}.size
    @shared_count = @company.content_folders.accessible_by(current_ability).where.not(user: @admin).count + @company.task_media.accessible_by(current_ability).where.not(user: @admin, is_pdf: true).count + @company.catchword_lists.accessible_by(current_ability).where.not(user: @admin, name: 'task_list').count + @company.objection_lists.where.not(user: @admin, name: 'task_list').count
    if !(can? :create, ContentFolder)
      if @peters_count == 0
        redirect_to dashboard_shared_content_path if @shared_count != 0
      elsif @shared_count == 0
        redirect_to dashboard_peters_content_path if @peters_count != 0
      end
    end
  end

  def my_content
    @folders = @company.content_folders.includes(:user).accessible_by(current_ability).where(content_folder: nil, user: @admin)
    @files = @company.task_media.includes(:user).accessible_by(current_ability).where(content_folder: nil, user: @admin).where.not(is_pdf: true)
    @pdfs = @company.task_pdfs.includes(:user).accessible_by(current_ability).where(content_folder: nil, user: @admin)
    @lists = []
    @company.catchword_lists.accessible_by(current_ability).where(content_folder: nil, user: @admin).where.not(name: 'task_list').each do |cl|
      @lists << {id: cl.id, type: 'catchword', name: cl.name}
    end
    @company.objection_lists.accessible_by(current_ability).where(content_folder: nil, user: @admin).where.not(name: 'task_list').each do |cl|
      @lists << {id: cl.id, type: 'objection', name: cl.name}
    end
    if params[:folder_id]
      @folder = ContentFolder.find(params[:folder_id])
      @folders = @folder.content_folders.accessible_by(current_ability)
      @files = @folder.task_media.accessible_by(current_ability).where.not(is_pdf: true)
      @pdfs = @folder.task_pdfs.accessible_by(current_ability)
      @lists = []
      @folder.catchword_lists.accessible_by(current_ability).each do |cl|
        @lists << {id: cl.id, type: 'catchword', name: cl.name, user_name: cl.user.fname[0] + '. ' + cl.user.lname}
      end
      @folder.objection_lists.accessible_by(current_ability).each do |cl|
        @lists << {id: cl.id, type: 'objection', name: cl.name, user_name: cl.user.fname[0] + '. ' + cl.user.lname}
      end
    end
    if params[:audio]
      @content = TaskMedium.find(params[:audio])
    elsif params[:image]
      @content = TaskMedium.find(params[:image])
    elsif params[:pdf]
      @content = TaskPdf.find(params[:pdf])
      @slides = @content.task_media
    elsif params[:video]
      @content = TaskMedium.find(params[:video])
    elsif params[:catchword]
      @listType = 'catchword'
      @liste = CatchwordList.find(params[:catchword])
    elsif params[:objection]
      @liste = ObjectionList.find(params[:objection])
    end
  end

  def update_media_options
    @task_media = TaskMedium.find(params[:media_id])
    @task_media.update(title: params[:title])
    render json: { id: params[:media_id], title: params[:title], type: params[:type] }
  end

  def update_folder_name
    @folder = ContentFolder.find(params[:folder_id])
    @folder.update(name: params[:name])
    render json: { id: params[:folder_id], name: params[:name] }
  end

  def shared_content
    @folders = @company.content_folders.includes(:user).accessible_by(current_ability).where(content_folder: nil).where.not(user: @admin)
    @files = @company.task_media.includes(:user).accessible_by(current_ability).where(content_folder: nil).where.not(user: @admin)
    @lists = []
    @company.catchword_lists.accessible_by(current_ability).where(content_folder: nil).where.not(user: @admin, name: 'task_list').each do |list|
      if list.user
        @lists << {id: list.id, type: 'catchword', name: list.name, user_name: list.user.fname[0] + '. ' + list.user.lname}
      else
        @lists << {id: list.id, type: 'catchword', name: list.name, user_name: 'Gelöschter Nutzer'}
      end
    end
    @company.objection_lists.accessible_by(current_ability).where(content_folder: nil).where.not(user: @admin, name: 'task_list').each do |list|
      if list.user
        @lists << {id: list.id, type: 'objection', name: list.name, user_name: list.user.fname[0] + '. ' + list.user.lname}
      else
        @lists << {id: list.id, type: 'objection', name: list.name, user_name: 'Gelöschter Nutzer'}
      end
    end
    if params[:folder_id]
      @folder = ContentFolder.find(params[:folder_id])
      @folders = @folder.content_folders
      @files = @folder.task_media
      @lists = []
      @folder.catchword_lists.each do |cl|
        @lists << {id: cl.id, type: 'catchword', name: cl.name}
      end
      @folder.objection_lists.each do |cl|
        @lists << {id: cl.id, type: 'objection', name: cl.name}
      end
    end
    if params[:audio]
      @content = TaskMedium.find(params[:audio])
    elsif params[:image]
      @content = TaskMedium.find(params[:image])
    elsif params[:pdf]
      @content = TaskMedium.find(params[:pdf])
    elsif params[:video]
      @content = TaskMedium.find(params[:video])
    elsif params[:catchword]
      @listType = 'catchword'
      @liste = CatchwordList.find(params[:catchword])
    elsif params[:objection]
      @liste = ObjectionList.find(params[:objection])
    end
  end

  def peters_content
    @folders = ContentFolder.where(content_folder: nil, available_for: 'global')
    @folders += ContentFolder.where(content_folder: nil, available_for: 'global_hidden')
    @files = TaskMedium.where(content_folder: nil, available_for: 'global').where.not(is_pdf: true)
    @files = TaskMedium.where(content_folder: nil, available_for: 'global_hidden').where.not(is_pdf: true)
    @lists = []
    CatchwordList.where(content_folder: nil, available_for: 'global').where.not(name: 'task_list').each do |cl|
      @lists << {id: cl.id, type: 'catchword', name: cl.name}
    end
    CatchwordList.where(content_folder: nil, available_for: 'global_hidden').where.not(name: 'task_list').each do |cl|
      @lists << {id: cl.id, type: 'catchword', name: cl.name}
    end
    ObjectionList.where(content_folder: nil, available_for: 'global').where.not(name: 'task_list').each do |cl|
      @lists << {id: cl.id, type: 'objection', name: cl.name}
    end
    ObjectionList.where(content_folder: nil, available_for: 'global_hidden').where.not(name: 'task_list').each do |cl|
      @lists << {id: cl.id, type: 'objection', name: cl.name}
    end
    if params[:folder_id]
      @folder = ContentFolder.find(params[:folder_id])
      @folders = @folder.content_folders
      @files = @folder.task_media.where.not(is_pdf: true)
      @lists = []
      @folder.catchword_lists.each do |cl|
        @lists << {id: cl.id, type: 'catchword', name: cl.name}
      end
      @folder.objection_lists.each do |cl|
        @lists << {id: cl.id, type: 'objection', name: cl.name}
      end
    end
  end

  def search_content
    level = params[:level]
    @folder = ContentFolder.find_by(id: params[:folder]) if params[:folder]
    if @folder
      files = TaskMedium.where(content_folder: @folder)
      folders = ContentFolder.where(content_folder: @folder)
      cw = CatchwordList.where(content_folder: @folder).where.not(name: 'task_list')
      ol = ObjectionList.where(content_folder: @folder).where.not(name: 'task_list')
    elsif level == 'root'
      files = TaskMedium.accessible_by(current_ability)
      folders = ContentFolder.accessible_by(current_ability)
      cw = CatchwordList.accessible_by(current_ability).where.not(name: 'task_list')
      ol = ObjectionList.accessible_by(current_ability).where.not(name: 'task_list')
    elsif level == 'user'
      files = TaskMedium.accessible_by(current_ability)
      folders = ContentFolder.accessible_by(current_ability)
      cw = CatchwordList.accessible_by(current_ability).where.not(name: 'task_list')
      ol = ObjectionList.accessible_by(current_ability).where.not(name: 'task_list')
    elsif level == 'shared'
      files = @company.task_media.where.not(user: @admin).accessible_by(current_ability)
      folders = @company.content_folders.where.not(user: @admin).accessible_by(current_ability)
      cw = @company.catchword_lists.where.not(user: @admin).accessible_by(current_ability).where.not(name: 'task_list')
      ol = @company.objection_lists.where.not(user: @admin).accessible_by(current_ability).where.not(name: 'task_list')
    elsif level == 'peters'
      files = TaskMedium.where(available_for: 'global')
      folders = ContentFolder.where(available_for: 'global')
      cw = CatchwordList.where(available_for: 'global').where.not(name: 'task_list')
      ol = ObjectionList.where(available_for: 'global').where.not(name: 'task_list')
    end
    @files = []
    @folders = []
    @lists = []
    if params[:search] && params[:search] != ''
      files.search(params[:search]).each do |file|
        if file.media_type == 'video' && file.video?
          @file = {id: file.id, type: "video", thumb: file.video.thumb.url, title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        elsif file.media_type == 'image' && file.image? && !file.is_pdf
          @file = {id: file.id, type: "image", thumb: file.image.url, title: file.title, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        elsif file.media_type == 'audio' && file.audio?
          @file = {id: file.id, type: "audio", title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        elsif file.media_type == 'pdf' && file.pdf?
          @file = {id: file.id, type: "pdf", title: file.title, author: file.user.fname[0] + '. ' + file.user.lname}
          @files << @file
        end
      end
      folders.search(params[:search]).each do |folder|
        @folder = {id: folder.id, title: folder.name, author: folder.user.fname[0] + '. ' + folder.user.lname }
        @folders << @folder
      end
      cw.search(params[:search]).each do |list|
        @lists << {id: list.id, name: list.name, entries: list.catchwords.count, type: 'catchword', user_name: (list.user.fname[0] + '. ' + list.user.lname)}
      end
      ol.search(params[:search]).each do |list|
        @lists << {id: list.id, name: list.name, entries: list.objections.count, type: 'objection', user_name: (list.user.fname[0] + '. ' + list.user.lname)}
      end
    else
      if level == 'root'
        render json: {standard: true}
        return
      elsif level == 'shared'
        files = @company.task_media.accessible_by(current_ability).where(content_folder: nil).where.not(user: @admin)
        folders = @company.content_folders.accessible_by(current_ability).where(content_folder: nil).where.not(user: @admin)
        cw = @company.catchword_lists.accessible_by(current_ability).where(content_folder: nil).where.not(user: @admin, name: 'task_list')
        ol = @company.objection_lists.accessible_by(current_ability).where(content_folder: nil).where.not(user: @admin, name: 'task_list')
      elsif level == 'user'
        files = @company.task_media.accessible_by(current_ability).where(content_folder: nil, user: @admin)
        folders = @company.content_folders.accessible_by(current_ability).where(content_folder: nil, user: @admin)
        cw = @company.catchword_lists.accessible_by(current_ability).where(content_folder: nil, user: @admin).where.not(name: 'task_list')
        ol = @company.objection_lists.accessible_by(current_ability).where(content_folder: nil, user: @admin).where.not(name: 'task_list')
      elsif level == 'peters'
        files = TaskMedium.where(available_for: 'global', content_folder: nil)
        files += TaskMedium.where(available_for: 'global_hidden', content_folder: nil)
        folders = ContentFolder.where(available_for: 'global', content_folder: nil)
        folders += ContentFolder.where(available_for: 'global_hidden', content_folder: nil)
        cw = CatchwordList.where(available_for: 'global', content_folder: nil).where.not(name: 'task_list')
        cw += CatchwordList.where(available_for: 'global_hidden', content_folder: nil).where.not(name: 'task_list')
        ol = ObjectionList.where(available_for: 'global', content_folder: nil).where.not(name: 'task_list')
        ol += ObjectionList.where(available_for: 'global_hidden', content_folder: nil).where.not(name: 'task_list')
      end
      if @folder
        files.each do |file|
          if file.media_type == 'video' && file.video?
            @file = {id: file.id, type: "video", thumb: file.video.thumb.url, title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
            @files << @file
          elsif file.media_type == 'image' && file.image? && !file.is_pdf
            @file = {id: file.id, type: "image", thumb: file.image.url, title: file.title, author: file.user.fname[0] + '. ' + file.user.lname}
            @files << @file
          elsif file.media_type == 'audio' && file.audio?
            @file = {id: file.id, type: "audio", title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
            @files << @file
          elsif file.media_type == 'pdf' && file.pdf?
            @file = {id: file.id, type: "pdf", title: file.title, author: file.user.fname[0] + '. ' + file.user.lname}
            @files << @file
          end
        end
        folders.each do |folder|
          @folder = {id: folder.id, title: folder.name, author: folder.user.fname[0] + '. ' + folder.user.lname }
          @folders << @folder
        end
        cw.each do |list|
          @lists << {id: list.id, name: list.name, entries: list.catchwords.count, type: 'catchword', user_name: (list.user.fname[0] + '. ' + list.user.lname)}
        end
        ol.each do |list|
          @lists << {id: list.id, name: list.name, entries: list.objections.count, type: 'objection', user_name: (list.user.fname[0] + '. ' + list.user.lname)}
        end
      else
        files.each do |file|
          if file.media_type == 'video' && file.video?
            @file = {id: file.id, type: "video", thumb: file.video.thumb.url, title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
            @files << @file
          elsif file.media_type == 'image' && file.image? && !file.is_pdf
            @file = {id: file.id, type: "image", thumb: file.image.url, title: file.title, author: file.user.fname[0] + '. ' + file.user.lname}
            @files << @file
          elsif file.media_type == 'audio' && file.audio?
            @file = {id: file.id, type: "audio", title: file.title, duration: (file.duration / 60).to_s + ':' + (file.duration % 60).to_s, author: file.user.fname[0] + '. ' + file.user.lname}
            @files << @file
          elsif file.media_type == 'pdf' && file.pdf?
            @file = {id: file.id, type: "pdf", title: file.title, author: file.user.fname[0] + '. ' + file.user.lname}
            @files << @file
          end
        end
        folders.where(content_folder: nil).each do |folder|
          @folder = {id: folder.id, title: folder.name, author: folder.user.fname[0] + '. ' + folder.user.lname }
          @folders << @folder
        end
        cw.where(content_folder: nil).each do |list|
          @lists << {id: list.id, name: list.name, entries: list.catchwords.count, type: 'catchword', user_name: (list.user.fname[0] + '. ' + list.user.lname)}
        end
        ol.where(content_folder: nil).each do |list|
          @lists << {id: list.id, name: list.name, entries: list.objections.count, type: 'objection', user_name: (list.user.fname[0] + '. ' + list.user.lname)}
        end
      end
    end
    render json: {folders: @folders, files: @files, lists: @lists}
  end

  def choose_company
    @company = @admin.companies.first
    @companies = @admin.companies.order(:name)
    if @companies.count == 1
      redirect_to login_company_path(@company.id)
    end
  end

  def index
  end

  def customize_game
	@game = Game.find(params[:game_id])
	@team = @game.team
	@uCL = @admin.catchword_lists.order('name')
	@cCL = @company.catchword_lists.where.not(user: @admin).order('name')
	@pCL = CatchwordList.where(company_id: nil, user_id: nil, game_id: nil).order('name')
	@uOL = @admin.objection_lists.order('name')
	@cOL = @company.objection_lists.where.not(user: @admin).order('name')
	@pOL = ObjectionList.where(company_id: nil, user_id: nil, game_id: nil).order('name')
	@uRL = @admin.rating_lists.order('name')
	@cRL = @company.rating_lists.where.not(user: @admin).order('name')
	@pRL = RatingList.where(company_id: nil, user_id: nil).order('name')
	@pitches = []
	@admin.games.each do |p|
	  p.game_turns.each do |t|
	  	if t.pitch_video && t.pitch_video.favorite
		  minutes = t.pitch_video.duration / 60
		  minutes = minutes < 10 ? '0' + minutes.to_s : minutes.to_s
		  seconds = t.pitch_video.duration % 60
		  seconds = seconds < 10 ? '0' + seconds.to_s : seconds.to_s
		  rating = t.ges_rating ? t.ges_rating / 10.0 : '?'
		  @pitches << {id: t.pitch_video.id, video: t.pitch_video, duration: minutes + ':' + seconds, word: t.catchword, user: t.user, rating: rating}
	  	end
	  end
	end
  end

  def teams
  @teams = @company.teams.includes(:users).accessible_by(current_ability)
	@team = Team.find(params[:team_id]) if params[:team_id]
  @users_count = @company.users.accessible_by(current_ability).count
	@users = @team.users.accessible_by(current_ability).order('lname') if params[:team_id] && params[:edit] != "true"
  @users = @company.users.accessible_by(current_ability).order('lname') if !@users
  if params[:edit_user]
     @user = User.find(params[:edit_user])
     @role = @user.company_users.find_by(company: @company).role if @user
     if !(can? :edit, @user)
       redirect_to dashboard_teams_path
     end
  end
  end

  def user_stats
	@user = User.find(params[:user_id])
	if @user.game_turn_ratings.where(company: @company).count == 0
    flash[:alert_head] = 'Keine Statistik vorhanden'
	  flash[:alert] = 'Der Spieler hat noch nicht gepitcht!'
    if can? :read, Team
      redirect_to dashboard_teams_path
 	    return
    else
      redirect_to dashboard_path
 	    return
    end
	end
	@user_ratings = []
	UserRating.where(company: @company, user: @user).each do |r|
	  @user_ratings << {icon: r.rating_criterium.icon, name: r.rating_criterium.name, rating: r.rating, id: r.rating_criterium.id}
	end
	@user_ratings = @user_ratings.sort_by{|e| -e[:name]}
	@days = 1
	@turns = @user.game_turns.order('created_at')
	date = @turns.first.created_at.beginning_of_day
	@chartdata = []
	@turns.each do |t|
	  bod = t.created_at.beginning_of_day
	  if date != bod
		@days += 1
		date = bod
	  end
    cust_rating = []
    cust_task = []
    ges_rating = []
	  if t.game_turn_ratings.count != 0
      my_rating = nil
	    t.game_turn_ratings.each do |tr|
        if t.ratings.find_by(rating_criterium: tr.rating_criterium, user: @admin)
  		    cust_rating << {id: tr.rating_criterium.id, name: tr.rating_criterium.name, rating: tr.rating / 10.0, my_rating: t.ratings.find_by(rating_criterium: tr.rating_criterium).rating / 10.0}
          if my_rating
            my_rating += tr.rating / 10.0
          else
            my_rating = tr.rating / 10.0
          end
        else
          cust_rating << {id: tr.rating_criterium.id, name: tr.rating_criterium.name, rating: tr.rating / 10.0}
        end
	    end
      my_rating = (my_rating / cust_rating.length).round(1) if my_rating
      if t.task.task_type == 'catchword'
        cust_task << {id: t.task, type: t.task.task_type, title: t.task.title, catchword: t.catchword.name}
      elsif t.task.task_medium_id.nil?
        cust_task << {id: t.task, type: 'deleted', title: t.task.title}
      elsif t.task.task_type == 'audio'
        cust_task << {id: t.task, type: t.task.task_type, title: t.task.title, audio: t.task.task_medium.audio.url}
      elsif t.task.task_type == 'image'
        cust_task << {id: t.task, type: t.task.task_type, title: t.task.title, image: t.task.task_medium.image.url}
      elsif t.task.task_type == 'video'
        cust_task << {id: t.task, type: t.task.task_type, title: t.task.title, video: t.task.task_medium.video.url}
      end
      ges_rating << {ges: t.ges_rating / 10.0, my_ges: my_rating}
	    @chartdata << {date: t.created_at.strftime('%d.%m.%Y'), task: cust_task, time: t.created_at.strftime('%H:%M'), ges: t.ges_rating / 10.0, ges_ratings: ges_rating, cust_ratings: cust_rating}
	  else
		@turns = @turns.except(t)
	  end
	end
  @turns = @turns.where.not(ges_rating: nil)
  TeamUser.where(user: @user).each do |t|
    @team = t.team if t.team.company == @company
  end
  if @team
    @team_place = []
    place = 1
    @team.users.sort_by{|e| - e[:ges_rating]}.each do |tu|
      @team_place << {place: place, id: tu.id, name: tu.fname, rating: (tu.ges_rating / 10.0)}
      place = place + 1
    end
    this_user = @team_place.find {|x| x[:id] == @user.id}
    if this_user[:place] == 1
      @first_user = @team_place.find {|x| x[:place] == 1}
      @second_user = @team_place.find {|x| x[:place] == 2}
      @third_user = @team_place.find {|x| x[:place] == 3}
    elsif this_user[:place] == @team_place.size
      @first_user = @team_place.find {|x| x[:place] == this_user[:place] - 2}
      @second_user = @team_place.find {|x| x[:place] == this_user[:place] - 1}
      @third_user = this_user
    else
      @first_user = @team_place.find {|x| x[:place] == this_user[:place] - 1}
      @second_user = this_user
      @third_user = @team_place.find {|x| x[:place] == this_user[:place] + 1}
    end
  end
  end

  def team_stats
	@team = Team.find(params[:team_id])
	if @team.games.count == 0 || @team.users.count == 0
	  flash[:alert] = 'Das Team hat noch keine Spiele'
	  redirect_to dashboard_teams_path
	  return
	end
	@team_ratings = []
	@team.team_ratings.each do |r|
	  sum = 0
	  tcount = 0
	  @team.users.each do |u|
		if u.user_ratings.find_by(rating_criterium: r.rating_criterium)
			sum += u.user_ratings.find_by(rating_criterium: r.rating_criterium).change
			tcount += 1
		end
	  end
	  @team_ratings << {icon: r.rating_criterium.icon, name: r.rating_criterium.name, rating: r.rating, change: sum / tcount / 10.0, id: r.rating_criterium.id}
	end
	@team_ratings = @team_ratings.sort_by{|e| -e[:name]}
	@days = 1
	@games = @team.games.order('created_at')
	date = @games.first.created_at.beginning_of_day
	@chartdata = []
	@games.each do |t|
	  bod = t.created_at.beginning_of_day
	  if date != bod
		@days += 1
		date = bod
	  end
	end
	@games = @games.where.not(ges_rating: nil)
	@games.each do |t|
	  cust_rating = []
	  t.game_ratings.each do |tr|
		cust_rating << {id: tr.rating_criterium.id, name: tr.rating_criterium.name, rating: tr.rating / 10.0,}
	  end
	  @chartdata << {date: t.created_at.strftime('%d.%m.%Y'), time: t.created_at.strftime('%H:%M'), ges: t.ges_rating / 10.0, cust_ratings: cust_rating}
	end
	@turns = @team.game_turns.where.not(ges_rating: nil)
	@team_users = @team.users.sort_by{|e| -e[:ges_rating]}
  end

  def account
  end

  def company
  end


  def video
    @pitches = []
    @videos = []
    count = 0
    game_hash = @company.pitch_videos.accessible_by(current_ability).joins(game_turn: :game).group("game_turns.game_id").count
    game_hash.each do |game_id, videos_count|
      @game = Game.find(game_id)
      video_present = false
      @game.game_turns.each do |gt|
        if gt.pitch_video.present?
          video_present = true
          v = gt.pitch_video
          minutes = v.duration / 60
          minutes = minutes < 10 ? '0' + minutes.to_s : minutes.to_s
          seconds = v.duration % 60
          seconds = seconds < 10 ? '0' + seconds.to_s : seconds.to_s
          rating = v.game_turn.ges_rating ? v.game_turn.ges_rating / 10.0 : '?'
          @videos << {id: gt.id, video: v, duration: minutes + ':' + seconds, title: gt&.task&.title, user: v.game_turn.user, rating: rating, pitch_id: count}
        end
      end
      if video_present
        title = @game.pitch.title if @game.pitch
        title = ' - - - ' if !title
        @pitches << {id: count, title: title, team_name: @game&.team&.name, created_at: @game.created_at}
        count += 1
      end
    end
  end

  def pitches
  @company_pitches = @company.pitches.accessible_by(current_ability)
  @global_pitches = Pitch.where(available_for: 'global').where.not(company: @company)
  @pitches = @global_pitches + @company_pitches
	@pitch = Pitch.find(params[:pitch_id]) if params[:pitch_id]
	@game = Game.find(params[:game_id]) if params[:game_id]
  @teams = @company.teams.accessible_by(current_ability)
  if @teams.count == 0
    @teams = []
    @admin.team_users.each do |t|
      @teams << t.team if t.team.company == @company
    end
  end
	@team = Team.find(params[:team]) if params[:team]
  end
  def new_pitch
	  if params[:global]
      @pitch = @admin.pitches.create(available_for: 'global_hold')
      redirect_to backoffice_pitches_path(edit_pitch: @pitch.id)
    else
      @pitch = @admin.pitches.create(company: @company)
      redirect_to dashboard_edit_pitch_path(@pitch)
    end
  end

  def pitch_video
    @turn = GameTurn.find(params[:turn_id])
    @task = @turn.task
    @ratings = @turn.game_turn_ratings
    @own_ratings = @turn.ratings.where(user: @admin).all
    @video = @turn.pitch_video
    @comments = @turn.comments.where.not(time: nil).order(:time)
  end

  def edit_pitch
  @pitches = @company.pitches.includes(task_orders: [task: [:task_medium]]).accessible_by(current_ability)
  @pitch = @pitches.select { |p| p.id == params[:pitch_id].to_i }.first
  if params[:task_id]
    @task = @pitch.tasks.find_by(id: params[:task_id])
    unless @task.present?
      @task = @pitch.task_orders.order(:order).first.task if @pitch.task_orders.present?
    end
		if params[:selected_card_order_id].present?
			if params[:type].present?
				task = Task.find(params[:selected_task_id])
				task_order = task.task_orders.first
				task_orders = TaskOrder.all.where("task_orders.pitch_id = ? and task_orders.order > ?", @pitch.id, task_order.order).order(:order)
			else
				task_orders = TaskOrder.all.where("task_orders.pitch_id = ? and task_orders.order > ?", @pitch.id, params[:selected_card_order_id]).order(:order)
			end
			if task_orders.present?
				set_order_id = task_orders.first.order
				order = set_order_id + 1
				task_orders.each do |task_order|
					task_order.update(order: order)
					order += 1
				end
				task_orders.find_by(task_id: @task.id).update(order: set_order_id)
			end
		end
	else
		@task = @pitch.task_orders.order(:order).first.task if @pitch.task_orders.present?
	end
	@cw_lists = @company.catchword_lists.accessible_by(current_ability).where.not(name: 'task_list')
  @cw_lists += CatchwordList.where(available_for: 'global').where.not(name: 'task_list')
  @cw_lists += CatchwordList.where(available_for: 'global_hidden').where.not(name: 'task_list')
	@ol_list = @company.objection_lists.accessible_by(current_ability).where.not(name: 'task_list')
  @ol_list += ObjectionList.where(available_for: 'global').where.not(name: 'task_list')
  @ol_list += ObjectionList.where(available_for: 'global_hidden').where.not(name: 'task_list')

	@folders = @admin.content_folders.where(content_folder: nil)
    @files = @admin.task_media.where(content_folder: nil)
    if params[:folder_id]
      @folder = ContentFolder.find(params[:folder_id])
      @folders = @folder.content_folders
      @files = @folder.task_media.order(:title)
	end
	if params[:selected_card_order_id]
		render json: { task_id: @task.id }
	end
  end

  def select_folder
  @pitch = Pitch.find(params[:id])
  @task = Task.find(params[:task_id])
  @type = params[:type]
	if params[:order] == 'first'
		@folders = @admin.content_folders.where(content_folder: nil)
    @files = @admin.task_media.where.not("#{params[:type].to_sym}" => nil).where(content_folder: nil)
	else
		@folder = ContentFolder.find(params[:folder_id])
		@folders = @folder.content_folders
    # @files = @folder.task_media.order(:title)
		@files = @folder.task_media.where.not("#{params[:type].to_sym}" => nil).order(:title)
	end
	respond_to do |format|
		format.js { render 'select_folder'}
	end
  end

  def add_media_content
    @pitch = Pitch.find(params[:id])
    @task = Task.find_by(id: params[:task_id])
    if params[:media_type] == 'pdf'
      @task_medium = TaskMedium.find(params[:media_id])
      path = @task_medium.pdf.current_path.split('/'+@task_medium.pdf.identifier)[0]
  	  images = Docsplit.extract_images( @task_medium.pdf.current_path, :output => path)
      Dir.chdir(path)
      images_array = []
      file_name = @task_medium.pdf.identifier.split('.')
      Dir.glob("*.png").length.times { |count| images_array << "#{file_name[0]}_#{count+1}.png"}
      images_array.each do |img|
          task_medium = TaskMedium.create(company: @pitch.company, user: @pitch.user, image: File.open(img), media_type: 'image', is_pdf: true, task_medium: @task_medium)
          File.delete(img)
          task = @pitch.tasks.create(company: @pitch.company, user: @pitch.user, task_type: "slide", task_medium: task_medium, valide: true)
        end
        @task = @pitch&.tasks&.last
    else
      selected_type = params[:selected_media_type].present? ? params[:selected_media_type] : params[:pdf_media_type]
      if params[:media_type] == selected_type || selected_type == 'bild'
        @pitch.tasks.find(params[:task_id]).update(task_medium_id: params[:media_id])
      end
    end
    render json: {id: @pitch.id, task_id: @task&.id}
  end

  def show_library_modal
    @type = params[:type]
    @pitch = Pitch.find(params[:id])
    @task = Task.find_by(id: params[:task_id])
    unless @task
      @task = @pitch&.tasks&.first
    end
    @folders = @admin.content_folders.where(content_folder: nil)
    @files = @admin.task_media.where.not("#{params[:type].to_sym}" => nil).where(content_folder: nil)
    respond_to do |format|
      format.js { render 'show_library_modal'}
    end
  end

  def select_task
    @pitch = Pitch.find(params[:pitch_id])
    @task = Task.find(params[:selected_task_id])
    @task_order = TaskOrder.find_by(pitch_id: @pitch.id, task_id: @task.id)
    @task_type = @task.task_type
    @admin = current_user
    @cw_lists = @company.catchword_lists.accessible_by(current_ability).where.not(name: 'task_list')
    @ol_list = @company.objection_lists.accessible_by(current_ability).where.not(name: 'task_list')
    @folders = @company.content_folders.accessible_by(current_ability).where(content_folder: nil)
    @files = ''
    @type = ''
    if @task.task_type != 'slide'
      @type = @task.task_type if @task.task_type == 'image' || @task.task_type == 'video' || @task.task_type == 'audio'
    else
      if @task.task_medium.present?
        @type = @task.task_medium.media_type
      else
        @type = @task.pdf_type
      end
    end

    @type ||= nil
    if @type.present?
      @files = @admin.task_media.where.not("#{@type.to_sym}" => nil).where(content_folder: nil)
    else
      @files = @admin.task_media.where(content_folder: nil)
    end
    respond_to do |format|
      format.js { render 'select_task'}
    end
  end

  def update_values
	  @task = Task.find(params[:selected_task_id])
	  @task.update(params[:type].to_sym => params[:value])
  end

  private
  	def set_user
  	  if user_signed_in?
  		    @admin = current_user
  	  else
  		  flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
  		  redirect_to root_path
  	  end
  	end
    def set_company
      if company_logged_in?
        @company = current_company
        @role = CompanyUser.find_by(user: @admin, company: @company).role
      else
        redirect_to dash_choose_company_path
      end
    end

    def check_inactive
      if company_logged_in? && user_signed_in?
        @company = current_company
        @admin = current_user
        @role = CompanyUser.find_by(user: @admin, company: @company).role
        @company.company_users.where(role: 'inactive_user').each do |du|
          @user = du.user
          @user.destroy if @user.company_users.count == 1
          du.destroy if @user
        end
        if @company.company_users.where(role: 'inactive').count != 0
          @inactive_users = []
          @company.company_users.where(role: 'inactive').each do |cu|
            @user = cu.user
            @gameUser = GameUser.find_by(user: @user)
            if @gameUser && @gameUser.game.user == @admin
              if (can? :create, User)
                @inactive_users << cu
              end
            elsif !GameUser.find_by(user: cu.user)
              @user = cu.user
              if @user.company_users.count == 1
                @user.destroy
              else
                cu.destroy
              end
            end
          end
        end
      end
    end
end
