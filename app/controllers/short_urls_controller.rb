class ShortUrlsController < ApplicationController
    def show 
        short_url = ShortURL.find_by_short_url(params[:short_url])
        if short_url
            if Time.now.utc > short_url.expires_at
                short_url.destroy
                @error_message = 'Sorry, the shorten url is expired.'
                render :error 
            else 
                short_url.increment!(:count)
                redirect_to short_url.url
            end
        else 
            @error_message = 'Oops, looks like the shorten url doesn''t exist.'
            render :error
        end
    end
end