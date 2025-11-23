# == Schema Information
#
# Table name: domain_names
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  site_id    :integer          not null
#
# Indexes
#
#  index_domain_names_on_name     (name) UNIQUE
#  index_domain_names_on_site_id  (site_id)
#
# Foreign Keys
#
#  site_id  (site_id => sites.id)
#
class DomainName < ApplicationRecord
  belongs_to :site

  validates :name, presence: true, uniqueness: true
end
