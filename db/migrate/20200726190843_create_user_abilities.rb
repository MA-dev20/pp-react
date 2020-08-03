class CreateUserAbilities < ActiveRecord::Migration[5.2]
  def change
    create_table :user_abilities do |t|
      t.belongs_to :company, foreign_key: true
      t.string :name
      t.string :role

      t.boolean :edit_company, default: false

      t.string :view_department, default: "none"
      t.string :create_department, default: "none"
      t.string :edit_department, default: "none"

      t.string :view_team, default: "none"
      t.string :create_team, default: "none"
      t.string :edit_team, default: "none"
      t.string :share_team, default: "none"

      t.string :view_stats, default: "user"

      t.string :view_pitch, default: "user"
      t.string :create_pitch, default: "none"
      t.string :edit_pitch, default: "none"
      t.string :share_pitch, default: "none"

      t.string :view_media, default: "user"
      t.string :create_media, default: "none"
      t.string :edit_media, default: "none"
      t.string :share_media, default: "none"

      t.timestamps
    end
  end
end
