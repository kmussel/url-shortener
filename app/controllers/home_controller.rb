class HomeController < ApplicationController

  def show 
    shorturl = ShortUrl.find_by!(key: params["key"])
    redirect_to shorturl.source
  end
end
