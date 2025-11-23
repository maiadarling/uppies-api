# == Schema Information
#
# Table name: sites
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  owner_type   :string           not null
#  status       :integer          default("created"), not null
#  storage_path :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  container_id :string
#  creator_id   :integer          not null
#  owner_id     :integer          not null
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
class Site < ApplicationRecord
  enum :status, created: 0, deploying: 1, live: 2, error: -1

  belongs_to :owner, polymorphic: true
  belongs_to :creator, class_name: 'User'

  def url
    "https://#{name}.uppies.dev"
  end
end
