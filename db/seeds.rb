require 'pry'

puts "--> Adding Seed Users"
puts "------------------------"

# Clean the existing entry, since this task should be repeatable
User.where(email: "john@example.com").destroy_all

# Clean our seed SuperAdmin
User.create(
  first_name: "John",
  last_name: "Doe",
  phone: "+1-555-555-5555",
  email: "john@example.com",
  password: "dragons",
  roles: [:super_admin])


puts "------------------------"
puts "--> Finished seeding"
