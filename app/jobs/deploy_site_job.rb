require "net/http"
require "uri"
require "json"

class DeploySiteJob < ApplicationJob
  queue_as :default

  MAX_RETRIES = 10
  RETRY_DELAY = 2

  def perform(site_id:)
    site = Site.find(site_id)

    site.update!(status: :deploying)

    # Execute Rails.root/bin/deploy-site with FULL_PATH and NAME as args
    command = "#{Rails.root}/bin/deploy-site #{site.storage_path} #{site.name}"
    puts "Running command: #{command}"
    output = `#{command}`

    puts "Output from deploy-site script: #{output}"

    # Parse the JSON output
    deploy_data = JSON.parse(output)

    site.update!(container_id: deploy_data["container_id"])

    puts "Deployment output: #{deploy_data.inspect}"

    prime_website(site.url)

    # Update site with deployment info
    site.update!(
      status: :live,
    )
  rescue => e
    site.update!(status: :error)
    raise e
  end

private

  def prime_website(url)
    uri = URI.parse(url)
    retries = 0

    loop do
      begin
        response = Net::HTTP.get_response(uri)
        break if response.code.to_i != 404
        retries += 1
        break if retries >= MAX_RETRIES
        sleep RETRY_DELAY
      rescue OpenSSL::SSL::SSLError => e
        puts "SSL Error encountered: #{e.message}. Retrying..."
        retries += 1
        break if retries >= MAX_RETRIES
        sleep RETRY_DELAY
        retry
      end
    end
  end
end
