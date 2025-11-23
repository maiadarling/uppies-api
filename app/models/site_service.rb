require "spicy-proton"

module SiteService
  include ParamsValidator

  def self.validate_or_generate_name
    loop do
      name = Spicy::Proton.pair
      return name unless Site.exists?(name: name)
    end
  end

  def self.create_release_for(site:, user:, archive_file_path:)
    site = resolve_object(Site, site)
    user = resolve_object(User, user)

    release = Release.transaction do
      release = Release.create!(site: site, deployed_by: user)
      release_path = release.storage_path

      unzip_archive(archive_file_path, release_path)

      release
    end
  end

  def self.start_site(site:, release: nil)
    site = resolve_object(Site, site)
    release = resolve_object(Release, release) if release.present?

    # If no release, get the most recent one
    release ||= site.releases.order(created_at: :desc).first
    raise "No releases found for site #{site.name}" if release.nil?

    container = orchestrator.start_container(
      image: "caddy:alpine",
      network: "uppies_net",
      name: "site_#{site.name}_#{SecureRandom.hex(4)}",
      volumes: {
        "#{release.storage_path}": "/usr/share/caddy"
      },
      labels: {
        "uppies.site" => "true",
        "uppies.site.name" => site.name,
        "uppies.site.id" => site.id.to_s,
        "uppies.creator.id" => site.creator_id.to_s,
        "uppies.owner.id" => site.owner_id.to_s,
        "uppies.owner.type" => site.owner_type,
        "traefik.enable" => "true",
        "traefik.http.routers.#{site.name}.rule" => build_host_rules(site),
        "traefik.http.routers.#{site.name}.entrypoints" => "websecure",
        "traefik.http.routers.#{site.name}.tls.certresolver" => "myresolver"
      }
    )

    release.update!(
      container_id: container.id,
      status: :live
    )

    return container.id
  end

  def self.stop_site(site:)
    site = resolve_object(Site, site)

    if site.container_id.present?
      orchestrator.stop_container(site.container_id)
    else
      containers = orchestrator.containers.select do |c|
        c.labels["uppies.site.id"] == site.id.to_s
      end

      containers.each do |container|
        orchestrator.stop_container(container.id)
      end
    end
  end

  def self.restart_site(site:, release: nil)
    site = resolve_object(Site, site)

    old_container_id = site.container_id
    new_container_id = start_site(site:, release:)

    if old_container_id.present?
      stop_site(site:)
      orchestrator.remove_container(old_container_id)
    end
  end

#private

  def self.build_host_rules(site)
    rules = ["Host(`#{site.uppies_domain}`)"]
    site.domain_names.each do |domain|
      rules << "Host(`#{domain.name}`)"
    end
    rules.join(" || ")
  end

  def self.orchestrator
    @orchestrator ||= ContainerOrchestrator.new
  end

  def self.unzip_archive(zip_path, extract_to)
    system("unzip", zip_path.to_s, "-d", extract_to.to_s)
  end
end
