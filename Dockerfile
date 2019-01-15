FROM jekyll/jekyll:stable

EXPOSE 4000
CMD bundle exec jekyll serve --host 0.0.0.0 --watch

WORKDIR /opt/ct
COPY ./Gemfile ./Gemfile.lock ./
RUN bundle install
