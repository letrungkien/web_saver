# Web Saver
This tool download a web page to your local machine. This tool is written in Ruby and using Selenium WebDriver to save web pages.

## How to use
```
Usage: ./fetch [flag] url...
    -m, --metadata                   Display saved metadata
    -h, --help                       Display usage information

./fetch https://www.google.com
./fetch -m https://www.google.com
site: https://www.google.com
num_links: 18
images: 4
last_fetch: 2022-12-21 07:03:45 UTC
```
## Install
### Run using Docker
- Make sure you have Docker installed: https://www.docker.com/products/docker-desktop/
- Build and start Selenium Chrome
```
docker-compose build
docker-compose up chrome
```
- It's ready to run
```
docker-compose run --rm app https://www.google.com
docker-compose run --rm app -m https://www.google.com
```

### Run from your machine
- Make sure you have Google Chrome installed: https://www.google.com/chrome/
- Update thess lines in `lib/web_saver.rb` as following:
```ruby
      #Selenium::WebDriver.for(:remote, options: options, url: 'http://chrome:4444/wd/hub')
      # use this to run without docker
      Selenium::WebDriver.for(:chrome, options: options)
```
- Then install necessary gems
```
gem install "selenium-webdriver"
gem install "down"
```
- It's ready to run
```
./fetch https://www.google.com
./fetch -m https://www.google.com
```
# Technologies
## Why Ruby?
- Ruby has English-like syntax and easy to use.
## Why Selenium?
- Most of websites on the Internet are having dynamic content.
- So other tools that deal with initial static html response from server like Nokogiri won't be enough to capture the whole content. 

# Improvements in the future
## Add tests
- I will need to write tests for it. Defintely end to end tests.
- The test will have a website with dynamic content as a given and check if html, assets, and metadata are downloaded.

## Save other assets
- There are other assets like js files, fonts, videos, etc. that I could save.

## Make download thread-safe
- Use [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) gem to handle concurrent download.
