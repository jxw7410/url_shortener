class ScraperWorker
    include Sidekiq::Worker 
    sidekiq_options retry: false 


    def perform(url, url_id)
        begin 
            raw_html = HTTParty.get(url)
            parse_page = Nokogiri::HTML(raw_html)
        rescue 
            parse_page = 'Untitled'
        end

        short_url = ShortURL.find_by_id(url_id)
        short_url.update(title: parse_page.title) if short_url
        
    end
end