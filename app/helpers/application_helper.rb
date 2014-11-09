module ApplicationHelper
  include DeviseHelper

  def bootstrap_devise_error_messages!
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t('errors.messages.not_saved',
                      count: resource.errors.count,
                      resource: resource.class.model_name.human.downcase)

    html = <<-HTML
    <div class="alert alert-danger alert-block">
    <button type="button" class="close" data-dismiss="alert">x</button>
    <h5>#{sentence}</h4>
    #{messages}
    </div>
    HTML

    html.html_safe
  end

  def body_tag
    "#{params[:controller]} #{params[:action]}"
  end

  def form_error_messages(resource)
    return '' if resource.errors.empty? or not resource

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    html = <<-HTML
    <div class="alert alert-danger alert-block">
    <button type="button" class="close" data-dismiss="alert">x</button>
    #{messages}
    </div>
    <hr/>
    HTML

    html.html_safe
  end

end
