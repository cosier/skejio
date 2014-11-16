class ScheduleRulesController < BusinessesController

  sidebar :schedule_rules
  before_filter :set_sidebar

  before_filter :provide_create_with_schedule_rule, only: [:create]
  skip_load_resource only: [:create]

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
    @offices = Office.business(@business)

    if @service_providers.empty?
      return redirect_to business_users_path,
        alert: "You must have at least one Service Provider before creating a Schedule Rule"
    end

    if @services.empty?
      return redirect_to business_services_path,
        alert: "You must have at least one Service before creating a Schedule Rule"
    end

    if @offices.empty?
      return redirect_to business_offices_path,
        alert: "You must have at least one Office before creating a Schedule Rule"
    end

    respond_with(@business, @schedule_rule)
  end

  def edit
  end

  def create
    @schedule_rule.service_provider_id = params[:schedule_rule][:service_provider_id]
    @schedule_rule.business_id = @business.id

    # @schedule_rule.save
    respond_with(@business, @schedule_rule)
  end

  def update
    @schedule_rule.update(schedule_rule_params)
    respond_with(@business, @schedule_rule)
  end

  def destroy
    @schedule_rule.destroy
    respond_with(@business, @schedule_rule)
  end

  private

  def provide_create_with_schedule_rule
    if authorize! :create, ScheduleRule
      @schedule_rule = ScheduleRule.new 
      @schedule_rule.attributes = schedule_rule_params.dup
    end
  end

  def set_sidebar
    set_current_sidebar :schedule_rules
  end

  def schedule_rule_params
    params.require(:schedule_rule)
    .permit(:service_provider_id, :business_id)
  end
end
