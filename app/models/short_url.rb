# == Schema Information
#
# Table name: short_urls
#
#  id         :bigint           not null, primary key
#  title      :string           default("")
#  url        :string           not null
#  short_url  :string           not null
#  count      :bigint           default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime
#


class ShortURL < ApplicationRecord
    # callback to create a unique short_url
    before_validation :ensure_unique_short_url, on: :create
    validates :url, :short_url, presence: true
    validates :url, length: {minimum: 10} 
    after_create :set_expiration


    def self.validate_url_format(url)
        # REGEX as follows http(s) optional, www. optional, [text.] mandatory, [text & symbols] mandatory.
        url.match /^((http|https):\/\/)?([\w.-]+\.)?([\w\.-]+\.)[\w\-\._~:\/\?#\[\]@!\$&'\(\)\*\+,;=]+$/ix
    end


    def self.url_wrap(url)
        url = 'http://' + url unless url.downcase.start_with?('http://') || url.downcase.start_with?('https://') 
        url
    end

    private 
    RETRIES = 5
    BASE_62_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    URL_LENGTH = 7

    
    def ensure_unique_short_url
        # Send is used because for whatever reason, a private method cannot be accessed via a callback.
        self.send('base62_encode')

        # Basically if short_url by the small chance already exists, I want to try again
        # with a high degree of randomness included.
        # Also doubles as validation
        # counter is set up in-case something happened such that the database is getting packed
        counter = 0
        while self.class.find_by_short_url(self.short_url) && counter < RETRIES
            self.send('base62_encode', SecureRandom::urlsafe_base64)
            counter += 1
        end

        self.short_url = "" if counter == RETRIES
    end

    def base62_encode(seed = "")
        # Find out how many bits you need for the length of url desired
        bits = (62 ** URL_LENGTH).to_s(2).length 

        # Create a MD5:hash, which always results in 128 bits   
        # MD5:hash returns a hex, which needs to be converted to binary
        # Then the binary is converted back to an integer
        num = Digest::MD5.hexdigest(self.url + seed)
            .to_i(16)
            .to_s(2)[0...bits]
            .to_i(2)
        
        self.short_url = ""
        while self.short_url.length < URL_LENGTH && num > 0
            self.short_url << BASE_62_CHARS[num % 62]
            num /= 62
        end

    end

    #sets expiration for url to expire in 1 year.
    def set_expiration
        self.expires_at = self.created_at + 1.year
        self.save!
    end
end
