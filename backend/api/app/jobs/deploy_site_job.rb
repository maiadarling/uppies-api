class DeploySiteJob < ApplicationJob
  queue_as :default

  def perform(site_id:)
    site = Site.find(site_id)

    site.deploying!

    # Execute Rails.root/bin/deploy-site with FULL_PATH and NAME as args
    command = "#{Rails.root}/bin/deploy-site #{site.storage_path} #{site.name}"
    puts "Running command: #{command}"
    output = `#{command}`

    puts "Output from deploy-site script: #{output}"

    # Parse the JSON output
    deploy_data = JSON.parse(output)

    puts "Deployment output: #{deploy_data.inspect}"

    # Update site with deployment info
    site.update!(
      status: :live
    )
  rescue => e
    site.update!(status: :error)
    raise e
  end
end
