class Award < ApplicationRecord
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'
  has_one_attached :certificate_image

  validates :title, presence: true
  validates :doctor_id, presence: true

  scope :recent_first, -> { order(date_received: :desc, created_at: :desc) }
end
