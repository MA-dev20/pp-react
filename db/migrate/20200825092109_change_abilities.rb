class ChangeAbilities < ActiveRecord::Migration[5.2]
  def change
    change_table :user_abilities do |t|
      t.remove :create_pitch
      t.remove :view_pitch
      t.remove :edit_pitch
      t.remove :share_pitch
      t.remove :create_media
      t.remove :view_media
      t.remove :edit_media
      t.remove :share_media
      t.string :create_content, default: 'none'
      t.string :view_content, default: 'none'
      t.string :edit_content, default: 'none'
      t.string :share_content, default: 'none'
    end
  end
end
