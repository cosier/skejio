require 'twilio-ruby'
require 'figaro'
require 'pry'

module Skej
  module Twilio

    class << self

      def buy_number(business, number)
        sub_account(business.sub_account).incoming_phone_numbers.create(:phone_number => number)
      end

      # Return a list of Available Incoming Numbers,
      # based on the search params given
      def search_available_numbers(business, search_params)
        sub_account(business.sub_account)
        .available_phone_numbers
        .get('US')
        .local
        .list(search_params)
      end

      # Handle creating sub accounts for a business
      def create_sub_account(business)
        raise "Business must not be nil" if business.nil?

        client.accounts.create(:friendly_name => business.slug, status: 'active')
      end

      # Lazy load the Twilio REST client
      def client
        @client ||= ::Twilio::REST::Client.new(
          ENV['TWILIO_ACCOUNT_SID'],
        ENV['TWILIO_AUTH_TOKEN'])
      end

      # Fetch a Twilio::REST::Account for a Business
      # SubAccount based on the stored sid
      def sub_account(sub_account)
        client.accounts.get(sub_account.sid)
      end

    end

  end
end
