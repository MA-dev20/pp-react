class AddFieldsToPitches < ActiveRecord::Migration[5.2]
  def change
    add_column :pitches, :video, :string
    add_column :pitches, :image, :string
  end
end
