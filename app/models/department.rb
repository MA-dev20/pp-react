class Department < ApplicationRecord
  mount_uploader :logo, LogoUploader

  belongs_to :company
  has_many :histories, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :department_users, :dependent: :destroy
  has_many :users, through: :department_users
  
  has_many :do_and_donts, dependent: :destroy
  has_many :videos, dependent: :destroy

  after_create do
	self.company.histories.create(history: 'Neue Abteilung erstellt: ' + self.name + '!', users: self.company.users.count, user_id: @user ? @user : nil, department_id: self.id)
  end
end
