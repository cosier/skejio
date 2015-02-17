module FactoryMacros

  def create_user(opts = {})
    options = opts.reverse_merge(
      email: "user-#{Random.rand(999)}@example.com",
      roles: [])
    binding.pry
    # Super admins don't have businesses associated with them,
    # so reproduce that here as well.
    if options[:roles].include? :super_admin
      options[:business] = false
    end

    create(:user, options)
  end


end
