class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_conversation_partner, only: [:index, :create]

  def index
    @conversations = current_user.conversations.includes(:avatar_attachment)

    if @other_user
      @messages = Message.between(current_user, @other_user)

      # Mark messages as read when opened
      @messages.where(receiver: current_user, read_at: nil).each(&:mark_as_read!)
    end

    audit_log(action: 'view_messages')
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    @message.receiver = @other_user

    if @message.save
      # Broadcast message via Turbo Stream for real-time updates
      broadcast_message(@message)

      # Create notification for receiver
      create_message_notification(@message)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to messages_path(user_id: @other_user.id), notice: 'Message sent.' }
      end

      audit_log(action: 'send_message', target: @other_user)
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('message-form', partial: 'form', locals: { message: @message, other_user: @other_user }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def mark_as_read
    message = current_user.received_messages.find(params[:id])
    message.mark_as_read!

    head :ok
  end

  private

  def set_conversation_partner
    if params[:user_id].present?
      @other_user = User.find(params[:user_id])
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def broadcast_message(message)
    # Broadcast to both sender and receiver
    Turbo::StreamsChannel.broadcast_append_to(
      "messages_#{message.sender_id}_#{message.receiver_id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: message, current_user: current_user }
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "messages_#{message.receiver_id}_#{message.sender_id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: message, current_user: message.receiver }
    )

    # Update unread count for receiver
    Turbo::StreamsChannel.broadcast_update_to(
      "notifications_#{message.receiver_id}",
      target: "unread-messages-count",
      html: message.receiver.unread_messages_count
    )
  end

  def create_message_notification(message)
    Notification.create!(
      user: message.receiver,
      notification_type: 'new_message',
      title: "New message from #{message.sender.full_name}",
      message: message.content.truncate(50),
      data: { message_id: message.id, sender_id: message.sender_id }
    )
  end
end
