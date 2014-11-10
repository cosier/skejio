class ScheduleRulesController < BusinessesController

  sidebar :schedule_rules

  def index
    @schedule_rules = ScheduleRule.all
    respond_with(@schedule_rules)
  end

  def show
    respond_with(@schedule_rule)
  end

  def new
    @service_providers = User.business(@business).service_providers
    @services = Service.business(@business)


    if @service_providers.empty?
      return redirect_to business_users_path,
        alert: "You must create a Service before creating a Schedule Rule"
    end

    if @services.empty?
      return redirect_to business_services_path,
        alert: "You must create a Service before creating a Schedule Rule"
    end

    respond_with(@schedule_rule)
  end

  def edit
  end

  def create
    @schedule_rule.save
    respond_with(@schedule_rule)
  end

  def update
    @schedule_rule.update(schedule_rule_params)
    respond_with(@schedule_rule)
  end

  def destroy
    @schedule_rule.destroy
    respond_with(@schedule_rule)
  end

  private

  def schedule_rule_params
    params.require(:schedule_rule)
    .permit(:service_provider_id, :business_id)
  end
end
