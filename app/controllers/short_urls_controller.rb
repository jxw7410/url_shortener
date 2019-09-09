class ShortUrlsController < ApplicationController
    def show 
        redirect_to 'https://google.com', status: 302
    end
end