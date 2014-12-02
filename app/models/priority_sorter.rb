class PrioritySorter

  class << self

    # Sort a mixed collection of ordered/unordered User(s)
    def sort!(collection)
      existing_orderings = collection.select(&:has_sort_order?).map(&:sort_order)
      heal! collection

      collection.select(&:has_not_sort_order?).each do |item|
        item.sort_order = (existing_orderings.max || 0) + 1
        existing_orderings << item.sort_order
        item.save!
      end

      collection
    end

    # Heals gaps in a ordered collection
    def heal!(collection)
      memory = {}
      changed = false

      collection.select(&:sort_order).sort_by(&:sort_order).each do |item|

        if memory[1].nil?
          memory[1] = item
          item.update(sort_order: 1)
          next
        end

        # Found duplicate sort_item
        if memory[item.sort_order]
          memory.sort.each do |order, item|
            if not memory[order + 1].present?
              memory[order+1] = item
              item.update(sort_order: order + 1)
              changed = true
              next
            end
          end

          next
        end

        # Found gap of 1
        if memory[item.sort_order.to_i - 1].nil?
          s = item.sort_order.to_i - 1
          s.times do |n|
            if memory[n].nil?
              memory[n] = item
              item.update(sort_order: n)
              changed = true
              next
            end
          end
        end

        if memory[item.sort_order].nil?
          memory[item.sort_order] = item
          next
        end

      end

      heal! collection if changed
    end

    def update_item_ordering(memory, item)
    end

  end
end

