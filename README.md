# URLShortener

## Technologies
* Ruby v.2.5.1
* Rails v.5.2.3
* Bundler v.2.0.1
* Postgresql
* Redis
* Sidekiq

## How to install
* The App has a docker config, so download Docker.

* Once Docker is installed, git clone this Repo.

* Docker configuration, as well as, other configs within the rails app are dependent on certain environment varibles. Create a .env file in the root directory of app, and copy the content of .sample.env to it.

* Before you do the next step, if you have postgresql running on your local machine on port 5432, turn off postgresql.

* In the terminal, or bash, run the following:
    > * ```chmod -x setup.sh ```
    > * ```bash setup.sh```

* After the installations are done, and no errors were present, open localhost:3000, and you should see a blank page with React Root.

* If you navigate to localhost:3000/sidekiq, you should see a UI for sidekiq

## How to close app
* Docker has the app running the background, which can be checked by using docker-compose ps. The containers for the apps can be stopped by using docker-compose stop or docker-compose down, although down would remove any data 

## How to Use
* At the moment there is no fancy ui, so API requests have to be done using curl commands, postman, etc, at least for POST requests.

* In your terminal you can run: 
    > ```curl -X POST -d "url=any_url"  http://localhost:3000/api/short_urls```

* This would return a json with a short_url, and the long url provided

* The short url is a hash, which works by simply using the link:
    > ```https://localhost:3000/<short_url>```

* Similiarly, if you want to fetch the top 100 most clicked url:
    > ```curl http://localhost:3000/api/short_urls```

* Or you can access the json via the browser by using the above url.

## SideKiq, and Redis
* SideKiq requires redis in order to queue up tasks to be executed asychronously. The task Sidekiq has to execute is simple, it executes a task to scrape the website, if it is a real website, for the title tag, using Nokogiri, and HTTParty.

* When a creates a shorten url, a task is sent to sidekiq to scrape the webpage. The user would not have to wait till the task is finish as the user gets back only a short url.

* The title, instead, is returned with the each of the URLs that were fetched from the top 100 url api request.

## URL shortener algorithm:
### Concept
```
BASE_62_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

URL_LENGTH = 7

def base62_encode(seed = "")
    bits = (62 ** URL_LENGTH).to_s(2).length 
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
```

* The algorithm uses both md5 and base62. In order for base62 to work, an integer is required. In this case the integer was acquired through md5. 

* The MD5 always return the same 128-bits for any given string. However, we don't need all 128-bits. Realistically we need only as many bits as relatively the longest URL length we want, which in this case is hard coded to 7. 62^7 would return an integer with a binary value of 42 bits. Therefore, 42 bits are stripped away from the 128-bits MD5. 62^7 also represents the total possible combinations of this hash.

* This algorithm could return a hash from anywhere with a length of 1 to 7.

### Collisions
* This algorithm is not fool proof when it comes to collision. Collisions will happen, although an algorithm is set in place to account for collisions to a degree:
```
RETRIES = 5
def ensure_unique_short_url
    
    self.send('base62_encode')

    counter = 0

    while self.class.find_by_short_url(self.short_url) && counter < RETRIES
        self.send('base62_encode', SecureRandom::urlsafe_base64)
        counter += 1
    end

    self.short_url = "" if counter == RETRIES
end
```
* SecureRandom is used to generated a randomized addition to the current url to add randomness to the MD5 hash to decrease the chances of subsequent collisions. However a limit is also set, simply because if, by chance the database gets too convoluted, and collision rates are at an all time high, a limit has to be set for how many tries the algorithms tries to generate a unique short url. If all attempts have failed, the short_url is set to an empty string, which would fail a validation.

### Thoughts
* The following algorithm was used to stress test collision rate of the algorithm: 

```
require 'digest'
require 'securerandom'

BASE_62_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

def base62_encode(url, length)
        bits = (62 ** length).to_s(2).length 
        num = Digest::MD5.hexdigest(url)
            .to_i(16)
            .to_s(2)[0..bits]
            .to_i(2)
            
        short_url = ""
        while( short_url.length != length )
            short_url << BASE_62_CHARS[num % 62]
            num /= 62
        end
        short_url
end

hash = Hash.new
collision = 0 
i = 0
while i < 30_000_000
    url = SecureRandom::urlsafe_base64
    t = base62_encode(url, 7)
    if hash.include?(t) && hash[t] != url
        collision += 1
    else 
        hash[t] = url
    end
    i += 1
end

puts collision
```

* Which resulted in several hundred collisions. 30 million was set assuming the scale of users creating url was about 1 million a day.

* However this shows that as database gets filled, the collisions would get exponentially worse. Least to say, this won't scale well.

* Something that is somewhat of an insurance that was set is, that all short URLs have expiration dates, set to 1 year ahead of when they were created. If an expired URL was used, the user won't get redirected, but instead get an error message. The expired URL extry would be deleted from the database as well.




