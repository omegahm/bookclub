FROM ruby:latest

RUN apt update && apt install memcached

RUN mkdir -p /var/www/bookclub
WORKDIR /var/www/bookclub

COPY . .
RUN bundle

ENTRYPOINT ["foreman", "start"]
