class ScheduleRulesController < BusinessesController
  load_and_authorize_resource

  @@sidebar = :schedule_rules

  def index
    @schedule_rules = ScheduleRule.all
    respond_with(@schedule_rules)
  end

  def show
    respond_with(@schedule_rule)
  end

  def new
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
