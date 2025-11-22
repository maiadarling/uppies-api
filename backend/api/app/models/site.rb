# == Schema Information
#
# Table name: sites
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  status       :integer          default("created"), not null
#  storage_path :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_sites_on_name  (name) UNIQUE
#
class Site < ApplicationRecord
  enum :status, created: 0, deploying: 1, live: 2, error: -1

  def url
    "https://#{name}.uppies.dev"
  end
end
