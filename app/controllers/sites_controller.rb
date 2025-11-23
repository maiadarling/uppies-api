require "spicy-proton"

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
    name = validate_or_generate_name(params[:name])
    base64_data = params[:data]

    site_folder = Rails.root.join("storage", "sites", name)
    FileUtils.mkdir_p(site_folder)

    temp_zip_path = decode_file(base64_data)
    unzip_archive(temp_zip_path, site_folder)
    File.delete(temp_zip_path)

    site = Site.new
    site.name = name
    site.storage_path = site_folder.to_s
    site.creator = current_user
    site.owner = current_user
    site.save!

    DeploySiteJob.perform_later(site_id: site.id)

    render json: {
      data: {
        name: site.name,
        url: site.url,
        status: site.status
      }
    }
  end

private

  def validate_or_generate_name(proposed_name)
    Spicy::Proton.pair
  end

  def decode_file(base64_data)
    zip_data = Base64.decode64(base64_data)
    temp_zip_path = Rails.root.join("tmp", "temp_#{Time.now.to_i}.zip")
    File.open(temp_zip_path, "wb") do |f|
      f.write(zip_data)
    end
    temp_zip_path
  end

  def unzip_archive(zip_path, extract_to)
    system("unzip", zip_path.to_s, "-d", extract_to.to_s)
  end
end
