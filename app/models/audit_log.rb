class AuditLog < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :target, polymorphic: true, optional: true

  # Validations
  validates :user, presence: true
  validates :action, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_action, ->(action) { where(action: action) }

  # Class methods
  def self.log(user:, action:, target: nil)
    create!(
      user: user,
      action: action,
      target: target
    )
  end
end
