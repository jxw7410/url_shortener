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
#


class ShortURL < ApplicationRecord
    # callback to create a unique short_url
    before_validation :ensure_unique_short_url, on: :create
    validates :url, :short_url, presence: true
    validates :url, length: {minimum: 10}
    validate :ensure_proper_url, on: :create 


    private 
    BASE_62_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    
    # Make sure the URL has proper formatting based on URI standards.
    def ensure_proper_url
        errors.add(:url, 'provided is not properly formatted.') unless self.url =~ URI::regexp
    end
    
    def ensure_unique_short_url
        url_length = 7
        # Send is used because for whatever reason, a private method cannot be accessed via a callback.
        self.send('base62_encode', url_length)

        # Basically if short_url by the small chance already exists, I want to try again
        # with a high degree of randomness included.
        # Also doubles as validation
        # counter is set up incase something happened such that the database is getting packed
        counter = 0
        while self.class.find_by_short_url(self.short_url) || counter != 10
            self.send('base62_encode', url_length, SecureRandom::urlsafe_base64)
            counter += 1
        end
    end

    def base62_encode(length, seed = "")
        # Find out how many bits you need for the length of url desired
        bits = (62 ** length).to_s(2).length 

        # Create a MD5:hash, which always results in 128 bits
        # MD5:hash returns a hex, which needs to be converted to binary
        # Then the binary is converted back to an integer
        num = Digest::MD5.hexdigest(self.url + seed)
            .to_i(16)
            .to_s(2)[0..bits]
            .to_i(2)
            
        while self.short_url.length < length && num > 0
            self.short_url << BASE_62_CHARS[num % 62]
            num /= 62
        end

    end
end
