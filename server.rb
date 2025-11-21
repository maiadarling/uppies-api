require 'webrick'
require 'base64'
require 'json'
require 'zip'
require 'fileutils'

STORAGE_FOLDER = "/root/uppies_sites"

def handle_sites_post(req)
  body = req.body
  data = JSON.parse(body)
  hostname = data['hostname'] || 'unknown'
  encoded_data = data['data']

  zip_data = Base64.decode64(encoded_data)

  # Create temp zip file
  temp_zip_path = "/tmp/#{hostname}_#{Time.now.to_i}.zip"
  File.open(temp_zip_path, 'wb') do |f|
    f.write(zip_data)
  end

  # Create site folder
  site_folder = File.join(STORAGE_FOLDER, hostname)
  FileUtils.mkdir_p(site_folder)

  # Unzip to site folder
  unzip_archive(temp_zip_path, site_folder)

  # Clean up temp file
  File.delete(temp_zip_path)

  'OK'
end

def unzip_archive(zip_path, extract_to)
  Zip::File.open(zip_path) do |zip_file|
    zip_file.each do |entry|
      entry_path = File.join(extract_to, entry.name)
      entry.extract(entry_path)
    end
  end
end

server = WEBrick::HTTPServer.new(:Port => 4369, :BindAddress => '0.0.0.0')

server.mount_proc '/sites' do |req, res|
  if req.request_method == 'POST'
    begin
      result = handle_sites_post(req)
      res.status = 200
      res.body = result
    rescue => e
      res.status = 400
      res.body = e.message
    end
  else
    res.status = 405
    res.body = 'Method Not Allowed'
  end
end

trap 'INT' do server.shutdown end
server.start