Rails.application.routes.draw do
  devise_for :users
  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	
  root 'landing#index'

  get 'product/', to: 'landing#product', as: 'product'
  get 'contact', to: 'landing#contact', as: 'contact'
  get 'blogs', to: 'landing#blogs', as: 'blog'
  get 'impressum', to: 'landing#impressum', as: 'impressum'
  get 'datenschutz', to: 'landing#datenschutz', as: 'datenschutz'
  get 'password/new', to: 'landing#new_password', as: 'forget_password'
  get 'accept_cookie', to: 'landing#accept_cookie', as: 'accept_cookies'
 
  get 'dashboard', to: 'dashboard#index', as: 'dashboard'
  get 'dashboard/games/:game_id/customize', to: 'dashboard#customize_game', as: 'dashboard_customize_game'
  get 'dashboard/teams', to: 'dashboard#teams', as: 'dashboard_teams'
  get 'dashboard/teams/:team_id', to: 'dashboard#teams', as: 'dashboard_team'
  get 'dashboard/teams/:team_id/stats', to: 'dashboard#team_stats', as: 'dashboard_team_stats'
  get 'dashboard/users/:user_id/stats', to: 'dashboard#user_stats', as: 'dashboard_user_stats'
  get 'dashboard/customize', to: 'dashboard#customize', as: 'dashboard_customize'
  get 'dashboard/video', to: 'dashboard#video', as: 'dashboard_video'
  get 'dashboard/video/pitch/:turn_id', to: 'dashboard#pitch_video', as: 'dashboard_pitch_video'
  get 'dashboard/account', to: 'dashboard#account', as: 'account'
	
  get 'dashboard/company', to: 'dash_company#index', as: 'company_dash'
  get 'dashboard/company/edit', to: 'dash_company#company', as: 'company_dash_edit'
  get 'dashboard/company/departments', to: 'dash_company#departments', as: 'company_dash_departments'
  get 'dashboard/company/departments/:department_id', to: 'dash_company#department', as: 'company_dash_department'
	
  get 'backoffice', to: 'backoffice#index', as: 'backoffice'
  get 'backoffice/companies', to: 'backoffice#companies', as: "backoffice_companies"
  get 'backoffice/companies/:company_id', to: 'backoffice#companies', as: "backoffice_company"
  get 'backoffice/catchwords', to: 'backoffice#catchwords', as: 'backoffice_catchwords'
  get 'backoffice/objections', to: 'backoffice#objections', as: 'backoffice_objections'
  get 'backoffice/ratings', to: 'backoffice#ratings', as: 'backoffice_ratings'
	
  # COMPANY
  post 'companies/register', to: 'company#register', as: 'register_company'
  post 'companies/new', to: 'company#new', as: 'new_company'
  get 'companies/:company_id/accept', to: 'company#accept', as: "accept_company"
  post 'companies/:company_id/edit', to: 'company#edit', as: 'edit_company'
  get 'companies/:company_id/destroy', to: 'company#destroy', as: 'destroy_company'
	
  #GAME DESKTOP
  get 'games/:game_id/join', to: 'game_desktop#join', as: 'gd_join'
	
  get 'games/game', to: 'game_desktop#game', as: "gd_game"
  get 'games/game/set_state', to: 'game_desktop#set_state', as: 'gd_set_state'
  get 'games/game/repeat', to: 'game_desktop#repeat', as: 'gd_repeat'
  get 'games/game/ended', to: 'game_desktop#ended', as: 'gd_ended'
	
  #GAME MOBILE
  get ':password', to: 'game_mobile#welcome', as: 'gm'
  get 'mobile/game/new_user', to: 'game_mobile#new_name', as: 'gm_new_name'
  get 'mobile/games/login', to: 'game_mobile#login', as: 'gm_login'
  
  get 'mobile/game/join', to: 'game_mobile#join', as: 'gm_join'	
  get 'mobile/game', to: 'game_mobile#game', as: 'gm_game'
  get 'mobile/game/choosen', to: 'game_mobile#choosen', as: 'gm_choosen'
  post 'mobile/game/objection', to: 'game_mobile#objection', as: "gm_objection"
  get 'mobile/game/set_state', to: 'game_mobile#set_state', as: "gm_set_state"
  get 'mibile/game/repeat', to: 'game_mobile#repeat', as: 'gm_repeat'
  get 'mibile/game/ended', to: 'game_mobile#ended', as: 'gm_ended'
	
  # GAMES
  post 'games/create', to: 'games#create', as: 'new_game'
  post 'games/:game_id/customize', to: 'games#customize', as: 'customize_game'
  post 'games/:game_id/email', to: 'games#email', as: 'email_game'
  post 'games/:game_id/users/:user_id/name', to: 'games#name', as: 'name_game'
  post 'games/:game_id/turns/:user_id/new', to: 'games#create_turn', as: 'new_turn'
  post 'games/turns/:turn_id/ratings/new', to: 'games#create_rating', as: 'new_rating'
  post 'games/turns/:turn_id/record_pitch', to: 'games#record_pitch', as: 'turn_record'
  post 'games/turns/:turn_id/upload_pitch', to: 'games#upload_pitch', as: 'upload_pitch'
	
  #TEAM
  post 'teams/create', to: 'teams#create', as: 'new_team'
  post 'teams/:team_id/edit', to: 'teams#edit', as: 'edit_team'
  put 'teams/:team_id/add/user/:user_id', to: 'teams#add_user'
  get 'teams/:team_id/delete/user/:user_id',to: 'teams#delete_user', as: 'delete_user_from_team'
	
  #USER
  post 'users/create', to: 'users#create', as: 'new_user'
  post 'users/:user_id/edit', to: 'users#edit', as: 'edit_user'
  put 'users/:user_id/avatar', to: 'users#edit_avatar', as: "update_avatar_user"
  get 'users/:user_id/destroy', to: 'users#destroy', as: 'destroy_user'
	
  #Customize
  post 'lists/new', to: 'customize#new_list', as: 'new_list'
  post 'lists/:list_id/edit', to: 'customize#edit_list', as: 'edit_list'
  post 'lists/:list_id/entry/add', to: 'customize#list_add_entry', as: 'list_add_entry'
  post 'lists/:list_id/sound/add', to: 'customize#list_add_sound', as: 'list_add_sound'
  post 'doanddonts/new', to: 'customize#new_doAndDont', as: "new_do_and_dont"
  post 'rating/:rating_criterium_id/edit', to: 'customize#edit_rating', as: 'edit_rating'
  put 'words/record/:id', to: 'customize#recordWord', as: "record_word"
  put 'objections/record/:id', to: 'customize#recordObjection', as: "record_objection"
  get 'delete/:type/:list/:id', to: 'customize#deleteEntry', as: 'delete_entry'
  get 'deletelist/:type/:list', to: 'customize#deleteList', as: 'delete_list'
end
