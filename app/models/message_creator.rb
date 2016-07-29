class MessageCreator
  attr_accessor :message, :sms_record

  def initialize(params)
    @message = Message.new(allowed_params(params))
  end

  def ok?
    save_message && send_notification
  end

  private

  #Send notification depending on the message format. 
  def send_notification
    if @message.msg_type == 'email'
      MessageMailer.secure_message(@message).deliver_now
    elsif @message.msg_type == 'sms'
      begin
      @twilio = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
      @sms_record = @twilio.account.messages.create(
        :from => @message.sender,
        :to => @message.recipient,
        :body => @message.secure_id
        )
      rescue StandardError => e
        puts e.message
     end
    end
  end

  def save_message
    @message.secure_id = SecureRandom.urlsafe_base64(25)
    @message.save
  end

  #Allow params based on message format
  def allowed_params(params)
    if params[:message][:msg_type] == 'email'
      return { sender_email: params[:message][:sender], recipient_email: params[:message][:recipient], body: params[:message][:body], msg_type: params[:message][:msg_type] }
    elsif params[:message][:msg_type] == 'sms'
      return { sender_phone: params[:message][:sender], recipient_phone: params[:message][:recipient], body: params[:message][:body], msg_type: params[:message][:msg_type] } 
    end
  end
end
