class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :thumbnail
      t.integer :time
      t.string :type
      t.string :catchwords
      t.string :catchword_ids
      t.string :image
      t.string :video
      t.string :audio
      t.string :reactions
      t.string :reaction_ids
      t.string :ratings
      t.references :user, foreign_key: true
      t.references :pitch, foreign_key: true

      t.timestamps
    end
  end
end
