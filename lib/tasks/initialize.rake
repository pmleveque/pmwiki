namespace :initialize do
  desc "TODO"
  task data: :environment do
    begin
      index = Tile.find(1)
    rescue
      index = Tile.new({:title => "index", :text => "", :id => 1})
      index.save
    end

    generated_tiles = []
    10.times do |i|
      t = Tile.new
      t.title = Forgery('name').company_name + " (#{i})"
      t.text = Forgery('lorem_ipsum').paragraph
      t.save
      generated_tiles.push(t)
    end

    generated_tiles.each do |t|
      index.text += "\n <a href='/tiles/#{t.id}'>#{t.title}</a>"
    end
    index.save

  end

  task reset: :environment do
    Tile.all.each do |t| t.destroy end
  end
end