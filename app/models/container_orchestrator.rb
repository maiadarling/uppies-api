require "docker"

class ContainerOrchestrator
  def initialize(sock_path: "~/.docker/run/docker.sock")
    @sock_path = File.expand_path(sock_path)
    Docker.url = "unix://#{@sock_path}"
  end

  def containers(with_labels: { 'uppies.site' => 'true' } )
    Docker::Container.all.filter_map do |container|
      info = container.info
      next unless matches_labels?(info, with_labels)

      build_container(container, info)
    end
  end

  def start_container(image:, network:, name:, volumes:, labels:)
    container = Docker::Container.create(
      'Image' => image,
      'HostConfig' => {
        'NetworkMode' => network,
        'Binds' => volumes.map { |host_path, container_path| "#{host_path}:#{container_path}" }
      },
      'Labels' => labels,
      'name' => name
    )

    container.start

    return Container.new(
      id: container.id,
      name: name,
      image: image,
      state: 'running',
      status: 'started',
      site_name: labels['uppies.site.name'],
      labels: labels
    )
  end

  def stop_container(container_id)
    container = Docker::Container.get(container_id)
    container.stop
  end

private

  def matches_labels?(info, labels)
    return true if labels.empty?

    container_labels = info['Labels'] || {}
    labels.all? { |key, value| container_labels[key] == value }
  end

  def build_container(container, info)
    name = info['Names'].first&.delete_prefix('/')
    site_name = info['Labels']['uppies.site.name'] if info['Labels']

    Container.new(
      id: container.id,
      name: name,
      image: info['Image'],
      state: info['State'],
      status: info['Status'],
      site_name: site_name,
      labels: info['Labels']
    )
  end

  class Container
    attr_accessor :id, :name, :image, :state, :status, :site_name, :labels

    def initialize(id:, name:, image:, state:, status:, site_name:, labels:)
      @id = id
      @name = name
      @image = image
      @state = state
      @status = status
      @site_name = site_name
      @labels = labels
    end
  end
end
