class CreateListEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :list_entries do |t|
      t.belongs_to :company, foreign_key: true
      t.belongs_to :user, foreign_key: true

      t.string :name
      t.string :sound

      t.timestamps
    end
  end
end
