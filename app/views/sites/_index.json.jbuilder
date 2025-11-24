json.array! object do |item|
  json.extract! item, :id, :status, :created_at

  json.creator do
    json.id item.creator_id
  end
end