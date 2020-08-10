class AddCoachToCompany < ActiveRecord::Migration[5.2]
  def change
    change_table :companies do |t|
      t.string :company_type, default: 'company'
    end
    drop_table :coaches
  end
end
