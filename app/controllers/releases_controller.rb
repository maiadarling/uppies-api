class ReleasesController < ApplicationController
  before_action :set_site

  def index
    @releases = @site.releases.order(created_at: :desc)

    return success!(data: @releases)
  end

  def create
    return error!("`data` parameter is required", status: :bad_request) unless params[:data].present?
    base64_data = params[:data]

    temp_zip_path = decode_file(base64_data)
    release = SiteService.create_release_for(site: @site, user: current_user, archive_file_path: temp_zip_path)
    File.delete(temp_zip_path)

    SiteService.restart_site(site: @site, release: release, delete: true)

    return success!("Release deployed", data: release)
  end

private

  def set_site
    @site = current_user.sites.find(params[:site_id])
    return error!("Site not found", status: :not_found) if @site.nil?
  end

  def decode_file(base64_data)
    zip_data = Base64.decode64(base64_data)
    random = SecureRandom.hex(8)
    temp_zip_path = Rails.root.join("tmp", "temp_#{random}_#{Time.now.to_i}.zip")

    File.open(temp_zip_path, "wb") do |f|
      f.write(zip_data)
    end

    temp_zip_path
  end
end
