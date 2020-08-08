class MakeContentAvailable < ActiveRecord::Migration[5.2]
  def change
    change_table :content_folders do |t|
      t.string :available_for, default: 'user'
    end
    change_table :task_media do |t|
      t.string :available_for, default: 'user'
    end
    change_table :catchword_lists do |t|
      t.string :available_for, default: 'user'
    end
    change_table :objection_lists do |t|
      t.string :available_for, default: 'user'
    end
    change_table :pitches do |t|
      t.string :available_for, default: 'user'
    end
  end
end
