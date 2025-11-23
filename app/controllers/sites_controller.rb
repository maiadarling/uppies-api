class SitesController < ApplicationController
  def index
    @sites = Site.all
    render json: {
      data: @sites.map { |site|
        {
          id: site.id,
          name: site.name,
          url: site.url,
          status: site.status
        }
      }
    }
  end

  def show
    site = Site.find_by(name: params[:name])
    if site.nil?
      render json: { error: "Site not found" }, status: :not_found
      return
    end

    render json: {
      data: {
        name: site.name,
        url: site.url,
        status: site.status
      }
    }
  end

  def create
    name = SiteService.validate_or_generate_name
    base64_data = params[:data]

    site = Site.transaction do
      temp_zip_path = decode_file(base64_data)

      site = Site.create!(name: name, creator: current_user, owner: current_user)
      release = SiteService.create_release_for(site: site, user: current_user, archive_file_path: temp_zip_path)
      SiteService.start_site(site: site, release: release)
      File.delete(temp_zip_path)

      site.live!

      site
    end

    render json: {
      data: {
        name: site.name,
        url: site.url,
        status: site.status
      }
    }
  end

private

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
