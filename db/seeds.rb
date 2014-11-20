puts "--> Adding Seed Users"
puts "------------------------"

# Clean the existing entry, since this task should be repeatable
User.where(email: "admin@example.com").destroy_all

super_roles = [
  :super_admin,
  :super_business_editor,
  :super_business_viewer,
]

# Clean our seed SuperAdmin
admin = User.create(
  first_name: "Admin",
  last_name: "S",
  phone: "+1-555-555-5555",
  email: "admin@example.com",
  password: "passme123",
  roles: super_roles)

# Clean our seed SuperAdmin
qa_admin = User.create(
  first_name: "Quality",
  last_name: "Assurance",
  phone: "+1-555-555-5555",
  email: "qa@example.com",
  password: "passme123",
  roles: super_roles)

raise admin.errors.to_json unless admin.persisted?
raise qa+admin.errors.to_json unless qa_admin.persisted?


puts "--> Finished seeding"
