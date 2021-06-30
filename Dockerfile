FROM jekyll/jekyll:4.2.0

EXPOSE 4000
CMD bundle exec jekyll serve --host 0.0.0.0 --watch

WORKDIR /opt/ct
USER root
COPY ./Gemfile ./Gemfile.lock ./
RUN bundle install
