require "spicy-proton"

module SiteService
  def self.validate_or_generate_name(name = nil)
    Spicy::Proton.pair
  end

  def self.launch_site(site:)
    raise ArgumentError, "Invalid site. Must be a Site or Integer" unless site.is_a?(Site) || site.is_a?(Integer)
    site = site.is_a?(Site) ? site : Site.find(site)

    container = orchestrator.start_container(
      image: "caddy:alpine",
      network: "uppies_net",
      name: "site_#{site.name}_#{SecureRandom.hex(4)}",
      volumes: {
        "#{site.storage_path}": "/usr/share/caddy"
      },
      labels: {
        "uppies.site" => "true",
        "uppies.site.name" => site.name,
        "uppies.site.id" => site.id.to_s,
        "uppies.creator.id" => site.creator_id.to_s,
        "uppies.owner.id" => site.owner_id.to_s,
        "uppies.owner.type" => site.owner_type,
        "traefik.enable" => "true",
        "traefik.http.routers.#{site.name}.rule" => "Host(`#{site.name}.uppies.dev`)",
        "traefik.http.routers.#{site.name}.entrypoints" => "websecure",
        "traefik.http.routers.#{site.name}.tls.certresolver" => "myresolver"
      }
    )

    site.update(container_id: container.id)

    return container.id
  end

  def self.stop_site(site:)
    raise ArgumentError, "Invalid site. Must be a Site or Integer" unless site.is_a?(Site) || site.is_a?(Integer)
    site = site.is_a?(Site) ? site : Site.find(site)

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

private

  def self.orchestrator
    @orchestrator ||= ContainerOrchestrator.new
  end
end
