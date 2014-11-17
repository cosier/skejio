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

    if @schedule_rule.save
      @s = @schedule_rule # shortcut it
      @bid = @business.id

      sheets = params[:schedule_rule][:sheets] and params[:schedule_rule][:sheets].dup

      # Create TimeSheet(s) on the ScheduleRule
      sheets.each do |sheet|
        time_sheet = @s.time_sheets.create(business_id: @bid)

        # Create TimeSheetServices if any services were specified
        sheet[:services].each do |service|
            time_sheet.time_sheet_services.create(service_id: service, business_id: @bid)
        end if sheet[:services].present?

        # Create Time Sheet Entries
        sheet[:entries].each do |entry|
          entry[:business_id] = @bid
          entry[:time_sheet_id] = time_sheet.id

          entry = convert_meridians(entry)

          time_sheet.time_entries.create entry.permit!
        end
      end if sheets

      # Create BreakShift(s) on the ScheduleRule
      params[:schedule_rule][:breaks].each do |brk|
        brk = convert_meridians(brk)
        @s.break_shifts.create brk.permit!
      end if params[:schedule_rule][:breaks].present?

    end

    respond_with(@business, @schedule_rule) do |format|
      format.js { render json: @schedule_rule }
    end
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

  def convert_meridians(entry)
    # convert meridians into 24 time
    if entry[:start_meridian].downcase == "pm"
      entry[:start_hour] = entry[:start_hour].to_i + 12
    end

    if entry[:end_meridian].downcase == "pm"
      entry[:end_hour] = entry[:end_hour].to_i + 12
    end

    entry.delete :start_meridian
    entry.delete :end_meridian

    entry
  end

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
