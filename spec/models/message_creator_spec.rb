require 'rails_helper' 

#Encapsulate the class MessageCreator with the describe block
describe MessageCreator do
  let(:creator) { MessageCreator.new ActionController::Parameters.new(message: message_params) }

  describe "#ok?" do
    subject { creator.ok? }
    context "with email params" do
      let(:message_params) do
        {
          sender: "test@example.com",
          recipient: "test2@example.com",
          body: "hello there",
          msg_type: "email"          
        }
      end
      it {should be_truthy}
      it "saves the message" do
        expect { subject }.to change { creator.message.new_record? }
      end
      it "sets a secure id" do
        expect { subject }.to change { creator.message.secure_id }
      end
      it "sends an email with a secure link" do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.body).to match(creator.message.secure_id)
        expect(email.body).to_not match(/hello there/)
      end
    end

    context "with sms params" do
      let(:message_params) do
        {
          sender: "15005550006",
          recipient: "4155551212",
          body: "hello there",
          msg_type: "sms"
        }
      end
      it {should be_truthy}
      it "saves the message" do
        expect { subject }.to change { creator.message.secure_id }
      end
      it "sets a secure id" do
        expect { subject }.to change { creator.message.secure_id }
      end
      it "does not send email" do
        expect { subject }.to_not change { ActionMailer::Base.deliveries.count }
      end
      it "sends an SMS with a secure link" do
        subject
        expect(creator.sms_record).to be_nil
        expect(creator.sms_record).to be_a(Twilio::REST::Message)
        expect(creator.sms_record.to).to eq("+14155551212")
        expect(creator.sms_record.body).to match(creator.message.secure_id)
        expect(creator.sms_record.body).to_not match(/hello there/)
      end
    end

    context "with bad params" do
      let(:message_params) {{
        sender: nil,
        recipient: "sad@example.com",
      }}
      it { should be_falsey }
      it "should not send email" do
        expect { subject }.to_not change { ActionMailer::Base.deliveries.count }
      end
      it "should not make a message" do
        expect { subject }.to_not change { Message.count }
      end
    end
  end

end
