class UserPriority

  class << self

    # Sort a mixed collection of ordered/unordered User(s)
    def sort!(users)
      existing_orderings = users.select(&:has_sort_order?).map(&:sort_order)
      heal! existing_orderings

      users.select(&:has_not_sort_order?).each do |user|
        user.sort_order = (existing_orderings.max || 0) + 1
        existing_orderings << user.sort_order
        user.save!
      end

      users
    end

    # Heals gaps in a ordered collection
    def heal!(collection)
      # todo
    end

  end
end

