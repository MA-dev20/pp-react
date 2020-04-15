class CreateObjectionListObjections < ActiveRecord::Migration[5.2]
  def change
    create_table :objection_list_objections do |t|
      t.belongs_to :objection_list, foreign_key: true
      t.belongs_to :objection, foreign_key: true

      t.timestamps
    end
  end
end
