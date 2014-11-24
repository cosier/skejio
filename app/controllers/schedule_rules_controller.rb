class ScheduleRulesController < BusinessesController

  before_filter :set_sidebar

  before_filter :provide_create_with_schedule_rule, only: [:create]
  before_filter :provide_business_basics, only: [:new, :edit, :show]
  before_filter :validate_requirements, only: [:new, :edit, :show]
  skip_load_resource only: [:create]

  include EntryHelper
  helper :entry
  sidebar :schedule_rules

  def index
    @schedule_rules = ScheduleRule.where(business_id: @business.id)
    respond_with(@schedule_rules)
  end

  def show
    respond_with(@schedule_rule)
  end

  def new
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
        time_sheet = @s.time_sheets.create!(business_id: @bid)

        # Create TimeSheetServices if any services were specified
        sheet[:services].each do |service|
            ss = TimeSheetService.create!(service_id: service, business_id: @bid, time_sheet_id: time_sheet.id)
        end if sheet[:services].present?

        # Create Time Sheet Entries
        sheet[:entries].each do |entry|
          entry[:business_id] = @bid
          entry[:time_sheet_id] = time_sheet.id

          entry = convert_meridians(entry)

          te = TimeEntry.create! entry.permit!
          raise te.errors.to_json if not te.persisted?

        end if sheet[:entries]
      end if sheets

      # Create BreakShift(s) on the ScheduleRule
      params[:schedule_rule][:breaks].each do |brk|
        brk[:business_id] = @bid
        brk[:schedule_rule_id] = @s.id

        brk = convert_meridians(brk)
        brk = convert_date_ranges(brk)
        bs = @s.break_shifts.create! brk.except(:services, :offices).permit!

        raise bs.errors.to_json if not bs.persisted?

        brk[:services].each do |service_id|
          bs.break_services.create!(break_shift_id: bs.id, service_id: service_id, business_id: @bid)
        end if brk[:services].present?

        brk[:offices].each do |office_id|
          bs.break_offices.create!(break_shift_id: bs.id, office_id: office_id, business_id: @bid)
        end if brk[:offices].present?


      end if params[:schedule_rule][:breaks].present?

    end

    flash[:success] = "Schedule Rule saved"

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

  def provide_business_basics
    @service_providers = User.business(@business).service_providers
    @services = Service.business(@business)
    @offices = Office.business(@business)
  end

  def validate_requirements
    if @service_providers.empty? and params[:action] != "show"
      return redirect_to business_users_path,
        alert: "You must have at least one AVAILABLE Service Provider before creating a Schedule Rule"
    end

    if @services.empty?
      return redirect_to business_services_path,
        alert: "You must have at least one Service before creating a Schedule Rule"
    end

    if @offices.empty?
      return redirect_to business_offices_path,
        alert: "You must have at least one Office before creating a Schedule Rule"
    end
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
    params.require(:schedule_rule).except(:sheets, :offices)
    .permit(:service_provider_id, :business_id)
  end
end
