json.array!(@tiles) do |tile|
  json.extract! tile, :id, :title, :text
  json.url tile_url(tile, format: :json)
end
