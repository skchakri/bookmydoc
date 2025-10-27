class Notification < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :title, presence: true
  validates :user, presence: true

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def unread?
    !read?
  end
end
