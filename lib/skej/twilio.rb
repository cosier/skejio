require 'twilio-ruby'
require 'figaro'

module Skej
  module Twilio

    class << self

      # Returns a newly purchased number's
      # sid
      # number
      def buy_number(business, number)
        binding.pry
        response = sub_account(business).incoming_phone_numbers.create(:phone_number => number)
        Rails.logger.info "Skej::Twilio#buy_number(#{business}, #{number}) -> #{response.to_json}"
        response
      end

      # Return a list of Available Incoming Numbers,
      # based on the search params given
      def search_available_numbers(business, search_params)
        # Process and format the contains field
        search_params['contains'] = format_containment(search_params['contains'])

        sub_account(business)
        .available_phone_numbers
        .get('US')
        .local
        .list(search_params)
      end

      # Handle creating sub accounts for a business
      def create_sub_account(business)
        raise "Business must not be nil" if business.nil?
        client.accounts.create(:friendly_name => "#{business.slug}-#{Random.rand(100..999}", status: 'active')
      end

      # Lazy load the Twilio REST client
      def client(sid = nil, auth = nil)
        ::Twilio::REST::Client.new(
          sid || ENV['TWILIO_ACCOUNT_SID'],
          auth || ENV['TWILIO_AUTH_TOKEN']
        )
      end

      # Get the rest client for a given business
      def sub_client(business)
        sid = business.sub_account.sid
        auth = business.sub_account.auth_token

        raise "Unknown Accessor Business: #{business} - #{sid}/#{auth}" unless sid and auth
        client(sid, auth)
      end

      # Get SubAccount rest api for a given Business
      def sub_account(business)
        sub_client(business).account
      end

      # Pad up the contains field with wildcard asterisk
      def format_containment(contains)
        if contains and contains.length < 11
          pad = ""

          # Max length is Ten
          (10 - contains.length).times.each do
            pad << "*"
          end

          contains = "1#{pad}#{contains}"
        end 

        contains
      end

    end
  end
end
