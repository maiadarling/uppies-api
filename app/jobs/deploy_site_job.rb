require "net/http"
require "uri"
require "json"

class DeploySiteJob < ApplicationJob
  queue_as :default

  def perform(site:)
    raise ArgumentError, "Invalid site. Must be a Site or Integer" unless site.is_a?(Site) || site.is_a?(Integer)
    site = site.is_a?(Site) ? site : Site.find(site)

    site.update!(status: :deploying)
    SiteService.start_site(site: site)
    site.update!(status: :live)

  rescue => e
    site.update!(status: :error)
    raise e
  end
end
