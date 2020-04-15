class CustomizeController < ApplicationController
  before_action :check_user
  def new_list
	authorize! :create, CatchwordList if params[:list][:type] == 'word'
	authorize! :create, ObjectionList if params[:list][:type] == 'objection'
	authorize! :create, RatingList if params[:list][:type] == 'rating'
	@list = @company.catchword_lists.new(list_params) if params[:list][:type] == 'word'
	@list = @company.objection_lists.new(list_params) if params[:list][:type] == 'objection'
	@list = @company.rating_lists.new(list_params) if params[:list][:type] == 'rating'
	@list.user = @admin
	flash[:alert] = "Konnte Liste nicht erstellen!" if !@list.save
	redirect_to dashboard_customize_path
  end
  def edit_list
	@list = @company.catchword_lists.find(params[:list_id]) if params[:list][:type] == 'word'
	@list = @company.objection_lists.find(params[:list_id]) if params[:list][:type] == 'objection'
	@list = @company.rating_lists.find(params[:list_id]) if params[:list][:type] == 'rating'
	authorize! :edit, @list
	flash[:alert] = "Konnte Liste nicht updaten!" if !@list.update(list_params)
	redirect_to dashboard_customize_path
  end
  def list_add_entry
	@list = @company.catchword_lists.find(params[:list_id]) if params[:type] == 'word'
	@list = @company.objection_lists.find(params[:list_id]) if params[:type] == 'objection'
	@list = RatingList.find(params[:list_id]) if params[:type] == 'rating'
	authorize! :edit, @list
	if params[:type] == 'word'
	  @entry = @company.catchwords.find_by(entry_params)
	  @entry = @company.catchwords.create(entry_params) if @entry.nil?
	  @list.catchwords << @entry if @list.catchwords.find_by(entry_params).nil?
	  redirect_to dashboard_customize_path('', CL: @list.id)
	elsif params[:type] == 'objection'
	  @entry = @company.objections.find_by(entry_params)
	  @entry = @company.objections.create(entry_params) if @entry.nil?
	  @list.objections << @entry if @list.objections.find_by(entry_params).nil?
	  redirect_to dashboard_customize_path('', OL: @list.id)
	elsif params[:type] == 'rating'
	  @entry = RatingCriterium.find_by(entry_params)
	  @entry = RatingCriterium.create(entry_params) if @entry.nil?
	  flash[:alert] = 'Zu viele Kriterien in Liste' if @list.rating_criteria.count == 4
	  @list.rating_criteria << @entry if @list.rating_criteria.find_by(entry_params).nil? && @list.rating_criteria.count < 4
	  redirect_to backoffice_ratings_path if params[:site] == 'backoffice_rating'
	  redirect_to dashboard_customize_path('', RL: @list.id) if !params[:site]
	end
  end
	
  def list_add_sound
	@list = CatchwordList.find(params[:list_id]) if params[:type] == 'word'
	@type = params[:type]
	@list = ObjectionList.find(params[:list_id]) if params[:type] == 'objection'
	if @list.company
	  @company = @list.company
	  params[:entry][:sound].each do |sound|
		@entry = @company.catchwords.find_by(name: sound.original_filename.split('.mp3').first) if @type == 'word'
		@entry = @company.objections.find_by(name: sound.original_filename.split('.mp3').first) if @type == 'objection'
		if @entry
		  @entry.update(sound: sound)
		  @list.catchwords << @entry if @type == 'word' && @list.catchwords.find_by(name: @entry.name).nil?
		  @list.objections << @entry if @type == 'objection' && @list.objections.find_by(name: @entry.name).nil?
		else
		  @list.catchwords.create(sound: sound, name: sound.original_filename.split('.mp3').first) if @type == 'word'
		  @list.catchwords.create(sound: sound, name: sound.original_filename.split('.mp3').first) if @type == 'objection'
		end
	  end
	else
	  params[:entry][:sound].each do |sound|
		@entry = Catchword.find_by(name: sound.original_filename.split('.mp3').first, company_id: nil) if @type == 'word'
		@entry = Objection.find_by(name: sound.original_filename.split('.mp3').first, company_id: nil) if @type == 'objection'
		if @entry
		  @entry.update(sound: sound)
		  @list.catchwords << @entry if @type == 'word' && @list.catchwords.find_by(name: @entry.name).nil?
		  @list.objections << @entry if @type == 'objection' && @list.objections.find_by(name: @entry.name).nil?
		else
		  @list.catchwords.create(sound: sound, name: sound.original_filename.split('.mp3').first) if @type == 'word'
		  @list.objections.create(sound: sound, name: sound.original_filename.split('.mp3').first) if @type == 'objection'
		end
	  end
	end
	redirect_to backoffice_catchwords_path if @type == 'word'
	redirect_to backoffice_objections_path if @type == 'objection'
  end
	
  def edit_rating
	@rating_criterium = RatingCriterium.find(params[:rating_criterium_id])
	@rating_criterium.update(icon: params[:rating][:icon])
	redirect_to backoffice_ratings_path
  end
	
  def new_doAndDont
	authorize! :create, DoAndDont
	@words = DoAndDont.create(user_id: @admin.id) if @admin.do_and_dont.nil?
	@words = @admin.do_and_dont if @admin.do_and_dont
	@words.does ||= []
	@words.donts ||= []
	@words.does << params[:word][:do] if !@words.does.include?(params[:word][:do]) && params[:word][:do]
	@words.donts << params[:word][:dont] if !@words.donts.include?(params[:word][:dont]) && params[:word][:dont]
	@words.save
	redirect_to dashboard_customize_path if params[:word][:do]
	redirect_to dashboard_customize_path('', words: 'dont') if params[:word][:dont]
  end
	
  private
	def list_params
	  params.require(:list).permit(:name)
	end
	def entry_params
	  params.require(:entry).permit(:name)
	end
	
    def check_user
	  if user_signed_in?
	    @admin = current_user
	    @company = @admin.company
	  else
	    flash[:alert] = 'Logge dich ein um dein Dashboard zu sehen!'
	    redirect_to root_path
	  end
	end
end