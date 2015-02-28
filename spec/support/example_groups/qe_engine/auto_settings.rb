module QEEngine
  module AutoSettings

    # By default we assume the full selection option.
    # Ie. ask for everything by default.
    def default_assumptions
      {
        office:   { val: Setting::OFFICE_SELECTION_ASSUME, id: :any },
        service:  { val: Setting::SERVICE_SELECTION_ASSUME, id: :any },
        provider: { val: Setting::USER_SELECTION_FULL_CONTROL, id: :any},
        priority: { val: Setting::USER_SELECTION_PRIORITY_RANDOM }
      }
    end

    def process_assumptions(opts)
      opts.map do |k,v|
        raise 'Must provide an Assumption key value' unless v[:val].present?

        # Conditionally set an instance variable based on the Klass#find record
        if v[:id].present?
          if v[:id] == :any
            model = k.to_s.classify.constantize.where(business_id: @business.id).first
          else
            model = k.to_s.classify.constantize.find(v[:id])
          end
          instance_variable_set("@#{k}", model)
          @session.store! "chosen_#{k}_id", model.id
        end

        # Persist setting struct
        Setting.install_key! assumption_name_to_setting_key(k), {
          business: @business,
          value: v[:val]
        }
      end
    end

    def assumption_name_to_setting_key(name)
      input = name.to_s.downcase.to_sym
      case input
      when :provider
        :user_selection
      when :service
        :service_selection
      when :office
        :office_selection
      else
        name
      end
    end


  end
end
