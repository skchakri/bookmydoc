class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'

  validates :content, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :between, ->(user1, user2) {
    where(
      "(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
      user1.id, user2.id, user2.id, user1.id
    ).order(created_at: :asc)
  }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update(read_at: Time.current) if read_at.nil?
  end

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end
end
