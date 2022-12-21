FROM ruby:2.7.6-alpine
#FROM selenium/standalone-chrome

WORKDIR /app
COPY . .

RUN gem install "selenium-webdriver"
RUN gem install "down"

RUN chmod +x fetch

ENTRYPOINT ["./fetch"]
