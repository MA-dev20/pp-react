class CreateListEntryLists < ActiveRecord::Migration[5.2]
  def change
    create_table :list_entry_lists do |t|
      t.belongs_to :list, foreign_key: true
      t.belongs_to :list_entry, foreign_key: true

      t.timestamps
    end
  end
end
