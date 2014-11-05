require 'rails_helper'
require "cancan/matchers"

describe 'business permissions', :type => :model do

  subject(:ability){ Ability.new(user) }

  let(:user){ nil }

  context "when user interacts with business" do

    let(:user){ create_user }

    it{ should     be_able_to :read, user.business }
    it{ should_not be_able_to :edit, user.business }
    it{ should_not be_able_to :read, create(:business)  }
  end

  context "when admin interacts with business" do

    let(:user){ create_user roles: [:admin] }
    # The admin can manage their own business
    it{ should     be_able_to :manage, user.business }

    # The admin cannot read anothers Business
    it{ should_not be_able_to :read, create(:business)  }
  end

  context "when super_admin interacts with business" do

    let(:user){ create_user roles: [:super_admin] }

    # The super_admin cannot do anything with a business
    it{ should_not be_able_to :read,  create(:business)  }
    it{ should_not be_able_to :edit,  create(:business)  }
  end

  context "when super_business_editor interacts with business" do

    let(:user){ create_user roles: [:super_business_editor] }

    # Only super_business_editor(s) can modify *any* business
    it{ should be_able_to :read,  create(:business)  }
    it{ should be_able_to :edit,  create(:business)  }
  end

  context "when super_business_viewer interacts with business" do
    let(:user){ create_user roles: [:super_business_viewer] }

    # Only super_business_view(s) can view *any* business
    it{ should be_able_to :read,  create(:business)  }
    it{ should_not be_able_to :edit,  create(:business)  }
  end

end
