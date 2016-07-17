FROM kazu69/ruby:2.3

RUN mkdir -p /var/www
WORKDIR /var/www

ADD ./Gemfile /var/www
ADD ./initialize.rb /var/www
ADD ./response /var/www/response

RUN mkdir -p log
RUN bundle install

EXPOSE 8080

CMD ["bundle", "exec", "ruby", "initialize.rb"]
