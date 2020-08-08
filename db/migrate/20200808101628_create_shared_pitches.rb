class CreateSharedPitches < ActiveRecord::Migration[5.2]
  def change
    create_table :shared_pitches do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :pitch, foreign_key: true
      t.timestamps
    end
  end
end
