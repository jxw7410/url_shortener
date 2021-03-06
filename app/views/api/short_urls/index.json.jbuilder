json.urls do 
    @urls.each do |url|
        json.set! url.id do 
            json.extract! url, :url, :short_url, :title
        end
    end
end

