module SystemLogHelper
  def customer_by_number(number)
    c = Customer.where(phone_number: number).first
    c.display_name
  end
end
