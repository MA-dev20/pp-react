class List < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :department, required: false
  belongs_to :team, required: false
  belongs_to :user, required: false
  belongs_to :content_folder, required: false
  has_many :list_entry_lists, dependent: :destroy
  has_many :list_entries, through: :list_entry_lists
  has_many :shared_contents, dependent: :destroy

  has_many :objection_lists
  has_many :catchword_lists

  before_destroy do
    self.objection_lists.each do |ol|
      ol.update(list: nil)
    end
    self.catchword_lists.each do |cw|
      cw.update(list: nil)
    end
  end

  def self.search(search)
    if search
      where('lower(name) LIKE ?', "%#{search.downcase}%")
    else
      scoped
    end
  end
end
