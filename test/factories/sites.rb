# == Schema Information
#
# Table name: sites
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  owner_type :string           not null
#  status     :integer          default("created"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  creator_id :integer          not null
#  owner_id   :integer          not null
#
# Indexes
#
#  index_sites_on_creator_id  (creator_id)
#  index_sites_on_name        (name) UNIQUE
#  index_sites_on_owner       (owner_type,owner_id)
#
# Foreign Keys
#
#  creator_id  (creator_id => users.id)
#
require "faker"

FactoryBot.define do
  factory :site do
    name { SiteService.validate_or_generate_name }
    storage_path { "/var/uppies/sites/#{name}" }
    status { :created }
    association :creator, factory: :user
    owner { creator }
  end
end
