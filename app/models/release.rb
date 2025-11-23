# == Schema Information
#
# Table name: releases
#
#  id             :integer          not null, primary key
#  status         :integer          default("created"), not null
#  storage_path   :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  container_id   :string
#  deployed_by_id :integer          not null
#  site_id        :integer          not null
#
# Indexes
#
#  index_releases_on_deployed_by_id  (deployed_by_id)
#  index_releases_on_site_id         (site_id)
#
# Foreign Keys
#
#  deployed_by_id  (deployed_by_id => users.id)
#  site_id         (site_id => sites.id)
#
class Release < ApplicationRecord
  enum :status, created: 0, deploying: 1, live: 2, stopped: 3, error: -1

  belongs_to :site
  belongs_to :deployed_by, class_name: "User"

  delegate :name, to: :site, prefix: true

  before_create :set_storage_path

private

  def set_storage_path
    release_stamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
    path = Rails.root.join("storage", "sites", "#{site_name}", "releases", release_stamp)
    FileUtils.mkdir_p(path) unless Dir.exist?(path)
    self.storage_path = path.to_s
  end

end
