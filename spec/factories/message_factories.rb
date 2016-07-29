FactoryGirl.define do
  factory :message do
    sender_email "sender@example.com"
    recipient_email "recipient@example.com"
    body "body text for the message"
    msg_type "email"    

  end
  trait :with_secure_id do
    secure_id { SecureRandom.urlsafe_base64(5) }
  end
end
