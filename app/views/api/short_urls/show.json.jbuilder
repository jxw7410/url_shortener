json.set! @short_url.id do 
    json.extract! @short_url, :url, :short_url, :title
end