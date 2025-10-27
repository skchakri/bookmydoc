class UnavailableDate < ApplicationRecord
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'

  validates :date, presence: true
  validates :date, uniqueness: { scope: :doctor_id }

  scope :for_date, ->(date) { where(date: date) }
  scope :upcoming, -> { where('date >= ?', Date.today).order(:date) }
  scope :past, -> { where('date < ?', Date.today).order(date: :desc) }
end
