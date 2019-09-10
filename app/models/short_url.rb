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
    validates :url, :short_url, presence: true
    validates :url, uniqueness: true
    validate :ensure_proper_url, on: :create 
    validate :ensure_unique_short_url, on: :create

    # This is done so a randomly generated tinyURL is ensured if this is used. This is also pre-validation stage
    # Therefore by running, valid?, all errors will be checked before the instance is actually persisted into the database.
    # SecureRandom string length is 4/3 of argument num. Currently set to length of 7, or 64^7 combinations
    def self.new_short_url(url)
        url_limit = 5 
        new_short_url = self.new(url: url, short_url: "")
        new_short_url.short_url = SecureRandom::urlsafe_base64(url_limit)
        new_short_url
    end

    # Make sure the URL has proper formatting based on URI standards.
    def ensure_proper_url
        errors.add(:url, 'provided is not properly formatted.') unless self.url =~ URI::regexp
    end

    # Not using uniqueness: true validation, so a custom error message can be used instead
    def ensure_unique_short_url
        errors.add(:short_url, 'cannot be created. Please try again.') if self.class.find_by_short_url(self.short_url)
    end
end
