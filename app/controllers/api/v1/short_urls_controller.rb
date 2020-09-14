class Api::V1::ShortUrlsController < ActionController::API
  include ActionController::MimeResponds

  def index
  end

  # GET /short_urls/1
  def show
    @shorturl = ShortUrl.find(params[:id])
    render json: @shorturl.to_json
  end

  # GET /short_urls/new
  def new
    @shorturl = ShortUrl.new
  end

  # POST /short_urls
  def create

    @shorturl = ShortUrl.new(shorturl_params)

    respond_to do |format|
      if @shorturl.save
        format.json { render json: @shorturl.to_json, status: :created }
      else
        format.json { render json: @shorturl.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /short_urls/1
  def update
  end

  # DELETE /short_urls/1
  def destroy
  end

  private

    # only allow the white list through.
    def shorturl_params
      params.require(:shorturl).permit(:source)
    end

end
