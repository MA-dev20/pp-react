Rails.application.routes.draw do
  devise_for :users, controllers: {
        sessions: 'users/sessions'
      }
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

  get 'dashboard/pitches', to: 'dashboard#pitches', as: 'dashboard'
  get 'dashboard/choose_company', to: 'dashboard#choose_company', as: 'dash_choose_company'
  get 'dashboard/games/:game_id/customize', to: 'dashboard#customize_game', as: 'dashboard_customize_game'
  get 'dashboard/teams', to: 'dashboard#teams', as: 'dashboard_teams'
  get 'dashboard/teams/:team_id', to: 'dashboard#teams', as: 'dashboard_team'
  get 'dashboard/teams/:team_id/stats', to: 'dashboard#team_stats', as: 'dashboard_team_stats'
  get 'dashboard/users/:user_id/stats', to: 'dashboard#user_stats', as: 'dashboard_user_stats'
  get 'dashboard/customize', to: 'dashboard#customize', as: 'dashboard_customize'
  get 'dashboard/video', to: 'dashboard#video', as: 'dashboard_video'
  get 'dashboard/video/pitch/:turn_id', to: 'dashboard#pitch_video', as: 'dashboard_pitch_video'
  get 'dashboard/account', to: 'dashboard#account', as: 'account'
  get 'dashboard/company', to: 'dashboard#company', as: 'dash_company'

  get '/dashboard/pitches', to: 'dashboard#pitches', as: 'dashboard_pitches'
  get '/dashboard/pitches/:id/edit_page', to: 'dashboard#select_folder', as: 'select_folder'
  get '/dashboard/pitches/:id/add_media', to: 'dashboard#add_media_content', as: 'add_media_content'
  get '/dashboard/pitches/:pitch_id/edit', to: 'dashboard#edit_pitch', as: 'dashboard_edit_pitch'
  get '/dashboard/:pitch_id/task/:task_id/select', to: 'dashboard#select_task', as: 'dashboard_select_task'
  get '/dashboard/:pitch_id/task/update_values', to: 'dashboard#update_values', as: 'dashboard_update_values'
  get 'dashboard/pitches/new', to: 'dashboard#new_pitch', as: 'dashboard_new_pitch'

  post '/dashboard/search_content', to: 'dashboard#search_content', as: 'search_content'

  put 'pitches/:id/update', to: 'pitches#update_pitch', as: 'update_pitch'

  get '/pitches/:id', to: 'pitches#delete_pitch', as: 'delete_unsave_pitch'
  get 'pitches/:pitch_id/tasks/:task_id/setTaskOrder/:order', to: 'pitches#set_task_order'
  post 'task/:pitch_id/task_media', to: 'pitches#create_task_media', as: 'create_task_media'
  post 'pitches/:id/pitch_media', to: 'pitches#create_pitch_media', as: 'create_pitch_media'
  get 'pitches/:id/pitch_media', to: 'pitches#destroy_pitch_media', as: 'destroy_pitch_media'
  post 'task/:pitch_id/task_media_content', to: 'pitches#create_task_media_content', as: 'create_task_media_content'
  post 'task/:pitch_id/video_url', to: 'pitches#update_video_url', as: 'update_video_url'
  get 'pitches/:pitch_id/task/new', to: 'pitches#create_task', as: 'create_task'
  post 'pitches/:pitch_id/task/:task_id/update', to: 'pitches#update_task', as: 'update_task'
  delete 'pitches/:pitch_id/task/:task_id/media', to: 'pitches#delete_media', as: 'delete_task_media'
  delete 'pitches/:pitch_id/task/:task_id/words', to: 'pitches#delete_words', as: 'delete_task_words'


  post 'tasks/:task_id/create_list', to: 'pitches#create_task_list', as: 'create_task_list'
  post 'pitches/:pitch_id/tasks/:task_id/create_ratings', to: 'pitches#create_ratings', as: 'create_ratings'
  get '/pitches/:pitch_id/task/:task_id/duplicate', to: 'pitches#copy_task', as: 'copy_task'
  get '/pitches/:id/duplicate', to: 'pitches#copy_pitch', as: 'copy_pitch'
  get '/pitches/:pitch_id/task/:task_id/destroy', to: 'pitches#delete_task', as: 'delete_task'
  get '/pitches/:pitch_id/task/destroy', to: 'pitches#delete_task_card', as: 'delete_task_card'

  post 'task_medium/new', to: 'task_media#create', as: 'create_media'
  post 'task_medium/:task_medium_id/update', to: "task_media#update", as: 'update_media'
  put 'task_medium/:task_medium_id/delete', to: "task_media#delete", as: 'delete_media'

  post 'content_folder/new', to: 'content_folder#new', as: 'new_folder'
  post 'content_folder/:folder_id/update', to: "content_folder#update", as: 'update_folder'
  put 'content_folder/:folder_id/delete', to: "content_folder#delete", as: 'delete_folder'

  post 'lists/new', to: 'list#create', as: 'create_list'
  post 'lists/:list_id/edit', to: 'list#update', as: 'edit_list'
  post 'lists/:list_id/addEntry', to: 'list#add_entry', as: 'list_add_entry'
  post 'lists/entry_edit', to: 'list#edit_entry', as: 'edit_entry'
  post 'lists/:type/entry/:entry_id', to: 'list#delete_entry', as: 'delete_entry'


  get 'backoffice', to: 'backoffice#index', as: 'backoffice'
  get 'backoffice/companies', to: 'backoffice#companies', as: "backoffice_companies"
  get 'backoffice/companies/:company_id', to: 'backoffice#company', as: "backoffice_company"
  get 'backoffice/catchwords', to: 'backoffice#catchwords', as: 'backoffice_catchwords'
  get 'backoffice/objections', to: 'backoffice#objections', as: 'backoffice_objections'
  get 'backoffice/ratings', to: 'backoffice#ratings', as: 'backoffice_ratings'

  # COMPANY
  post 'companies/register', to: 'company#register', as: 'register_company'
  post 'companies/new', to: 'company#new', as: 'new_company'
  get 'companies/:company_id/login', to: 'company#login', as: 'login_company'
  get 'companies/:company_id/accept', to: 'company#accept', as: "accept_company"
  post 'companies/:company_id/edit', to: 'company#edit', as: 'edit_company'
  get 'companies/:company_id/destroy', to: 'company#destroy', as: 'destroy_company'
  put 'companies/:company_id/edit_logo', to: 'company#edit_logo', as: 'edit_logo_company'

  #GAME DESKTOP
  get 'games/:game_id/join', to: 'game_desktop#join', as: 'gd_join'
  get 'games/game', to: 'game_desktop#game', as: "gd_game"
  get 'games/game/set_slide/:slide', to: 'game_desktop#set_slide', as: 'gd_set_slide'
  get 'games/game/set_state', to: 'game_desktop#set_state', as: 'gd_set_state'
  get 'games/game/repeat', to: 'game_desktop#repeat', as: 'gd_repeat'
  get 'games/game/ended', to: 'game_desktop#ended', as: 'gd_ended'

  #GAME MOBILE
  get ':password', to: 'game_mobile#welcome', as: 'gm'
  get 'mobile/game/new_user', to: 'game_mobile#new_name', as: 'gm_new_name'
  get 'mobile/games/login', to: 'game_mobile#login', as: 'gm_login'
  get 'mobile/games/turns/:turn_id/delete', to: 'game_mobile#delete_turn', as: 'gm_delete_turn'
  put 'mobile/games/turns/:turn_id/delete_task', to: 'game_mobile#delete_task_user', as: 'gm_delete_task'
  get 'mobile/games/turns/:turn_id/logout', to: 'game_mobile#logout', as: 'gm_logout'
  get 'mobile/games/turns/:turn_id/task/:task_id', to: 'game_mobile#set_task_user', as: 'gm_set_task_user'

  put 'mobile/game/addTime', to: 'game_mobile#add_time', as: 'gm_add_time'
  get 'mobile/game/join', to: 'game_mobile#join', as: 'gm_join'
  get 'mobile/game', to: 'game_mobile#game', as: 'gm_game'
  put 'mobile/game/set_timer', to: 'game_mobile#set_timer', as: 'gm_set_timer'
  put 'mobile/game/send_emoji', to: 'game_mobile#send_emoji', as: 'gm_send_emoji'
  get 'mobile/game/choosen', to: 'game_mobile#choosen', as: 'gm_choosen'
  post 'mobile/game/objection', to: 'game_mobile#objection', as: "gm_objection"
  get 'mobile/game/set_slide/:slide', to: 'game_mobile#set_slide', as: 'gm_set_slide'
  get 'mobile/game/set_state', to: 'game_mobile#set_state', as: "gm_set_state"
  get 'mobile/game/turn_repeat', to: 'game_mobile#repeat_turn', as: 'gm_repeat_turn'
  get 'mobile/game/repeat', to: 'game_mobile#repeat', as: 'gm_repeat'
  get 'mobile/game/ended', to: 'game_mobile#ended', as: 'gm_ended'
  get 'mobile/game/error', to: 'game_mobile#error', as: 'gm_error'


  # DEPARTMENT
  post 'departments/new', to: 'department#new', as: "new_department"
  post 'department/:department_id/edit', to: 'department#edit', as: 'edit_department'
  get 'departments/:department_id/destroy', to: 'department#destroy', as: "destroy_department"
  put 'departments/:department_id/add_user/:user_id', to: 'department#add_user', as: 'add_user_to_department'
  get 'departments/:department_id/delete_user/:user_id', to: 'department#delete_user', as: 'delete_user_from_department'
  # GAMES
  post 'games/create', to: 'games#create', as: 'new_game'
  post 'games/:game_id/customize', to: 'games#customize_game', as: 'customize_game'
  post 'games/:game_id/email', to: 'games#email', as: 'email_game'
  post 'games/:game_id/users/:user_id/name', to: 'games#name', as: 'name_game'
  post 'games/:game_id/users/:user_id/new', to: 'games#create_game_user', as: 'new_game_user'
  post 'games/turns/:turn_id/ratings/new', to: 'games#create_rating', as: 'new_rating'
  post 'games/turns/:turn_id/record_pitch', to: 'games#record_pitch', as: 'turn_record'
  post 'games/turns/:turn_id/upload_pitch', to: 'games#upload_pitch', as: 'upload_pitch'
  put 'games/pitches/:pitch_id/favorite', to: 'games#favorite_pitch', as: 'favorite_pitch'
  get 'games/pitches/:pitch_id/destroy_pitch', to: 'games#destroy_pitch', as: 'delete_pitch'
  post 'games/:game_id/set_rating_user', to: 'games#rating_user', as: 'set_rating_user'

  #TEAM
  post 'teams/create', to: 'teams#create', as: 'new_team'
  post 'teams/:team_id/edit', to: 'teams#edit', as: 'edit_team'
  get 'teams/:team_id/destroy', to: 'teams#destroy', as: 'destroy_team'
  put 'teams/:team_id/add/user/:user_id', to: 'teams#add_user'
  get 'teams/:team_id/delete/user/:user_id',to: 'teams#delete_user', as: 'delete_user_from_team'

  #USER
  post 'company/:company_id/users/create', to: 'users#create', as: 'new_user'
  post 'users/:user_id/edit', to: 'users#edit', as: 'edit_user'
  post '/users/new_password', to: 'users#new_password', as: 'user_new_password'
  post 'company/:company_id/users/activate_users', to: 'users#activate_users', as: 'activate_users'
  put 'users/:user_id/avatar', to: 'users#edit_avatar', as: "update_avatar_user"
  get 'users/:user_id/destroy', to: 'users#destroy', as: 'destroy_user'
  put 'company/:company_id/users/:user_id/make_root', to: 'users#root', as: 'make_root'
  put 'company/:company_id/users/:user_id/make_admin', to: 'users#admin', as: 'make_admin'
  put 'company/:company_id/users/:user_id/make_user', to: 'users#user', as: 'make_user'

  #Customize
  post 'doanddonts/new', to: 'customize#new_doAndDont', as: "new_do_and_dont"
  post 'rating/:rating_criterium_id/edit', to: 'customize#edit_rating', as: 'edit_rating'
  put 'words/record/:id', to: 'customize#recordWord', as: "record_word"
  put 'objections/record/:id', to: 'customize#recordObjection', as: "record_objection"
  
  get 'deletelist/:type/:list', to: 'customize#deleteList', as: 'delete_list'
  get 'delete/doAndDont/', to: 'customize#deleteDoAndDont', as: 'delete_doAndDont'

  #Comments
  post 'turns/:turn_id/comments/new', to: 'comments#create', as: 'new_comment'
  post 'turns/:turn_id/comments/add_comment', to: 'comments#add_comment', as: 'add_comment'
  post 'turns/:turn_id/comments/:comment_id/update', to: 'comments#update', as: 'update_comment'
  get 'turns/:turn_id/comments/:comment_id/destroy', to: 'comments#destroy', as: 'destroy_comment'

  #VIDEOS
  post 'videos/new', to: 'video#new', as: "new_video"
  post 'videos/:video_id/edit', to: 'video#edit', as: 'edit_video'
  get 'videos/:video_id/destroy', to: 'video#destroy', as: 'delete_video'

  #User Abilities
  post "company/:company_id/abilities/update/:role", to: 'user_abilities#update', as: 'update_user_abilities'
end
