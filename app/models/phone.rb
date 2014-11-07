# == Schema Information
#
# Table name: phones
#
#  id            :integer          not null, primary key
#  subaccount    :string(255)
#  number        :string(255)
#  phonable_id   :integer
#  phonable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  sid           :string(255)
#  sauth_token   :string(255)
#

class Phone < ActiveRecord::Base
  belongs_to :phonable, polymorphic: true


  # Getting all subaccount from twillio

  def self.all_subaccounts
    TwillioClient.accounts.list
  end

  def create_client_for_subaccount
    # Creating new client for sub account
    sa_client = Twilio::REST::Client.new(sid, sauth_token)
    subaccount = sa_client.account
  end

  def get_phone_numbers
    subaccount = create_client_for_subaccount
    # get a list of available numbers
    numbers = subaccount.available_phone_numbers.get('US').local.list({:area_code => '410'})

  end

  def buy_phone_number(number)
    subaccount = create_client_for_subaccount
    # buy the first one
    subaccount.incoming_phone_numbers.create(:phone_number => number)
    number
  end

  def send_sms(message)
    subaccount = create_client_for_subaccount
    begin
      msg = subaccount.messages.create(
        :from => number , # From our Twilio number
        :to => message[:to], # To any number
        :body => message[:body]
      )
    rescue Twilio::REST::RequestError => e
      e.message
    end

  end


  def make_a_call(info)
    subaccount = create_client_for_subaccount
    call = subaccount.calls.create(
      :from => number,   # From our Twilio number
      :to => info[:to],     # To any number
      # Fetch instructions from this URL when the call connects
      :url => 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
    )
  end

  def call_charges
    subaccount = create_client_for_subaccount
    # print a list of calls
    time_to_bill=0
    start_time = Time.now - ( 30 * 24 * 60 * 60) #30 days
    subaccount.calls.list({:page => 0, :page_size => 1000, :start_time => ">#{start_time.strftime("%Y-%m-%d")}"}).each do |call|
      time_to_bill += (call.duration.to_f/60).ceil
    end
    time_to_bill
  end


  def message_charges
    subaccount = create_client_for_subaccount
    total_charge = 0
    start_time = Time.now - ( 30 * 24 * 60 * 60) #30 days
    subaccount.messages.list({:page => 0, :page_size => 1000, :start_time => ">#{start_time.strftime("%Y-%m-%d")}"}).each do |msg|
      total_charge += msg.price.to_f
    end
    total_charge
  end


end
