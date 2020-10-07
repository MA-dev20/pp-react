class DropCatchwordList < ActiveRecord::Migration[5.2]
  def change
    change_table :shared_contents do |t|
      t.remove :catchword_list_id, :objection_list_id
      t.belongs_to :list, foreign_key: true
    end
    change_table :game_turns do |t|
      t.remove :catchword_id
      t.belongs_to :list_entry, foreign_key: true
    end
    change_table :catchword_lists do |t|
      t.remove :company_id, :user_id, :game_id, :name, :image, :content_folder_id, :available_for, :department_id, :team_id
      t.belongs_to :list, foreign_key: true
      t.boolean :valide, default: false
    end
    change_table :objection_lists do |t|
      t.remove :company_id, :user_id, :game_id, :name, :image, :content_folder_id, :available_for, :department_id, :team_id
      t.belongs_to :list, foreign_key: true
    end
    create_table :catchword_list_entries do |t|
      t.belongs_to :catchword_list, foreign_key: true
      t.belongs_to :list_entry, foreign_key: true
    end
    create_table :objection_list_entries do |t|
      t.belongs_to :objection_list, foreign_key: true
      t.belongs_to :list_entry, foreign_key: true
    end
    drop_table :objection_list_objections
    drop_table :objections
    drop_table :catchword_list_catchwords
    drop_table :catchwords
  end
end
