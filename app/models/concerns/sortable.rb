module Sortable
  extend ActiveSupport::Concern

  included do
  end


  def has_sort_order?
    sort_order and sort_order > 0
  end

  def has_not_sort_order?
    not has_sort_order?
  end

  def sort_order_desc
    "#{name} - #{sort_order}"
  end


end
