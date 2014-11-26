require 'twilio-ruby'
require 'figaro'

module Skej
  module Twilio

    class << self

      def application
        if Rails.env.production?
          friendly_name = "schedule_planner_production"
        else
          friendly_name = "schedule_planner_dev"
        end
        client.account.applications.list(friendly_name: friendly_name).first
      end

      # Returns a newly purchased number's
      # sid
      # number
      def buy_number(business, number)
        phone_request = {
          :phone_number => number,
          :sms_method   => 'GET',
          :voice_method => 'GET',
          :sms_url      => "#{ENV['PROTOCOL']}://#{ENV['HOST']}/twilio/sms",
          :voice_url    => "#{ENV['PROTOCOL']}://#{ENV['HOST']}/twilio/voice"
        }
        response = sub_account(business).incoming_phone_numbers.create(phone_request)
        Rails.logger.info "Skej::Twilio#buy_number(#{business}, #{number})"

        response
      end

      def update_number(opts)
        number = sub_account(opts[:sub_account_sid]).incoming_phone_numbers.get(opts[:sid])
        number.update(opts)
      end

      # Return a list of Available Incoming Numbers,
      # based on the search params given
      def search_available_numbers(business, search_params = {})
        # Process and format the contains field
        search_params['contains'] = format_containment(search_params['contains'])
        results = sub_account(business)
          .available_phone_numbers
          .get('US')
          .local
          .list(search_params)

        results
      end

      # Handle creating sub accounts for a business
      def create_sub_account(business)
        raise "Business must not be nil" if business.nil?
        client.accounts.create(:friendly_name => "#{business.slug}-#{business.id}", status: 'active')
      end

      def create_capability(opts = {})
        ::Twilio::Util::Capability.new opts[:sid] || ENV['TWILIO_ACCOUNT_SID'], opts[:auth_token] || ENV['TWILIO_AUTH_TOKEN']
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
      def sub_account(accessor)
        if accessor.kind_of? String
          sid = accessor
        else
          sid = accessor.sub_account.sid
        end

        #sub_client(business).account
        client.accounts.get(sid)
      end

      # Get all Sub Accounts
      def sub_accounts(conditions = {})
        client.accounts.list(conditions)
      end

      # Pad up the contains field with wildcard asterisk
      def format_containment(contains)
        if contains and contains.to_s.length < 11
          contains = contains.to_s
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
