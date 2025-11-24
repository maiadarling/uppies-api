json.array! object do |item|
  json.extract! item, :id, :site_id, :status, :created_at

  json.deployed_by do
    json.extract! item.deployed_by, :id
  end
end