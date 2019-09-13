class Api::ShortUrlsController < ApplicationController
    # For post request to allow for CORS for debugger purposes. To be removed.
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :ensure_params_url, only: [:create]

    # Checks if the URL user inputted already exists in DB
    # If it does, return that URL. Otherwise create a new one.
    def create
        url = ShortURL.url_wrap(params[:url])
        @short_url = ShortURL.find_by_url(url)
        if @short_url
            render :show 
        else 
            @short_url = ShortURL.new(url: url)
            if @short_url.save
                # short_url.url may be modified depending on the input
                ScraperWorker.perform_async(url, @short_url.id)
                render :show 
            else 
                render json: @short_url.errors.full_messages, status: 422 
            end
        end
    end 

    def index 
        @urls = ShortURL.all.limit(100).order(count: :desc)
        render :index
    end

    private
    # Callback to sure the url is properly formatted 
    def ensure_params_url
        if !params[:url]
            render json: ['No URL has been provided.'], status: 422 
        else 
            render json: ['Url format is Improper.'], status: 422 unless ShortURL.validate_url_format(params[:url])
        end
    end

end