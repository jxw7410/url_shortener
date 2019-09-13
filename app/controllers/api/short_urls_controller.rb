class Api::ShortUrlsController < ApplicationController
    # For post request to allow for CORS for debugger purposes. To be removed.
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :ensure_params_url, only: [:create]

    # Checks if the URL user inputted already exists in DB
    # If it does, return that URL. Otherwise create a new one.
    def create
        @short_url = ShortURL.find_by_url(params[:url])
        if @short_url
            render :show 
        else 
            @short_url = ShortURL.new(url: params[:url])
            if @short_url.save
                ScraperWorker.perform_async(params[:url], @short_url.id)
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
    def ensure_params_url
        render json: ['No URL has been provided'], status: 422 unless params[:url]
    end
end