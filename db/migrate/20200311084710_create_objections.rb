class CreateObjections < ActiveRecord::Migration[5.2]
  def change
    create_table :objections do |t|
      t.belongs_to :company, foreign_key: true
      t.string :name
      t.string :sound

      t.timestamps
    end
  end
end
