class PickupsController < ApplicationController
  def show
    @message = Message.where(secure_id: params[:id]).first!
    @reply = MessageCreator.new(message: {sender: @message.recipient, recipient: @message.sender, msg_type: @message.msg_type}).message
  end
end
