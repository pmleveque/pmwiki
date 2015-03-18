class BoardController < ApplicationController
  def index
    @tiles = Tile.all
  end
end
