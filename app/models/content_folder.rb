class ContentFolder < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :department, required: false
  belongs_to :team, required: false
  belongs_to :user
  belongs_to :content_folder, required: false
  has_many :content_folders, dependent: :destroy
  has_many :task_media
  has_many :objection_lists
  has_many :catchword_lists
  validates :name, presence: true

  before_destroy do
    @media = TaskMedium.where(content_folder: self)
    @catchwords = CatchwordList.where(content_folder: self)
    @objections = ObjectionList.where(content_folder: self)
    @media.each do |m|
      m.update(content_folder: nil)
    end
    @catchwords.each do |c|
      c.update(content_folder: nil)
    end
    @objections.each do |o|
      o.update(content_folder: nil)
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
