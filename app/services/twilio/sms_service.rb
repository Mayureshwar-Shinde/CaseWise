require 'twilio-ruby'

module Twilio
  class SmsService
    def send_sms communication
      account_sid = ENV['ACCOUNT_SID']
      auth_token = ENV['AUTH_TOKEN']
      @client = Twilio::REST::Client.new(account_sid, auth_token)

      message_body = "\nSubject: #{communication.subject}\nFrom: #{communication.from.full_name}\nMessage: #{communication.message}"
      message = @client.messages.create(
        body: message_body,
        from: '+15005550006',
        to: communication.to.phone
      )

      display_sms_details(message)
    end

    private

    def display_sms_details message
      puts "\n\n\n\n\n\n\n\n"
      puts "SMS: #{message}"
      puts "From: #{message.from}"
      puts "To: #{message.to}"
      puts "\nBody: \n#{message.body}"
      puts "\nSID: #{message.sid}"
      puts "\n\n\n\n\n\n\n\n"
    end
  end
end
