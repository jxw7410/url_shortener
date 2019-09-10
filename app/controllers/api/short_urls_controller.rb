class Api::ShortUrlsController < ApplicationController
    # For postman debugging
    skip_before_action :verify_authenticity_token, only: [:create]

    # Checks if the URL user inputted already exists in DB
    # If it does, return that URL. Otherwise create a new one.
    def create
        url = http_wrap(params[:url])
        @short_url = ShortURL.find_by_url(url)
        if @short_url
            render :show 
        else 
            @short_url = ShortURL.new_short_url(url)
            if @short_url.valid?
                @short_url.save!
                ScraperWorker.perform_async(url, @short_url.id)
                render :show 
            else 
                render @short_url.errors.full_messages, status: 422 
            end
        end
    end 

    def index 
        @urls = ShortURL.all.limit(100)
        render :index
    end

    private
    def http_wrap url
        url = 'http://' + url unless url.starts_with?('http://') || url.starts_with?('https://')
        url
    end
end