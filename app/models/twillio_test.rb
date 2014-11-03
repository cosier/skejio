class TwillioTest < ActiveRecord::Base



  def send_sms 
  	
  	#begin 
  	TwillioClient.account.messages.create({
					:from => '+14107532170', 
					:to => to_number, 
					:body => body ,  
	})
    #rescue Twilio::REST::RequestError =>  e
    	#return e.message
    #end

  end



  def subaccount

	#mock data for our newly created local application user
	local_user = {:id=>"100", :first_name=>"John", :last_name=>"Smith", :email=>"john@smith.com", :twilio_account_sid=>nil, :twilio_auth_token=>nil}

	#create a new Twilio subaccount
	@subaccount = TwillioClient.accounts.create({:FriendlyName => local_user[:email]})

	#update and save our local_user
	local_user[:twilio_account_sid] = @subaccount.sid
	local_user[:twilio_auth_token] = @subaccount.auth_token
	#local_user.save
	@sub_account_client = Twilio::REST::Client.new(@subaccount.sid, @subaccount.auth_token)
	@subaccount = @sub_account_client.account
	@numbers = @subaccount.available_phone_numbers.get('US').local.list({:area_code => '858'})

    # get a list of available numbers
	@numbers = @subaccount.available_phone_numbers.get('US').local.list({:area_code => '858'})
	puts "Available numbers:"
	@numbers.each {|num| puts num.phone_number}

	# buy the first one
	@subaccount.incoming_phone_numbers.create(:phone_number => @numbers[0].phone_number)

  end







end
