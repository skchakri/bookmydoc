class Review < ApplicationRecord
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'

  validates :rating, presence: true, inclusion: { in: 1..5, message: "must be between 1 and 5" }
  validates :doctor_id, uniqueness: { scope: :patient_id, message: "has already been reviewed by this patient" }

  scope :recent, -> { order(created_at: :desc) }
  scope :with_rating, ->(rating) { where(rating: rating) }

  def self.average_rating
    average(:rating).to_f.round(1)
  end

  def self.total_count
    count
  end

  def stars_array
    (1..5).map { |i| i <= rating }
  end
end
