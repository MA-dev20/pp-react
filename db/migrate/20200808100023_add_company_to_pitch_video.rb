class AddCompanyToPitchVideo < ActiveRecord::Migration[5.2]
  def change
    change_table :pitch_videos do |t|
      t.belongs_to :company, foreign_key: true
    end
  end
end
