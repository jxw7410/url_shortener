class ScraperWorker
    include Sidekiq::Worker 
    # will retry 3 times, and then disappear. Not storing a dead queue, because there is 
    # no plans, nor requirements to handle a dead request.
    sidekiq_options retry: 3, dead: false 

    def perform(url, url_id)
        # In the events that a false link was given, and nothing could've been extracted
        # At least set a title using a Hash.
        raw_html = HTTParty.get(url)
        parse_page = Nokogiri::HTML(raw_html)


        short_url = ShortURL.find_by_id(url_id)
        short_url.update(title: parse_page.title) if short_url
        
    end
end