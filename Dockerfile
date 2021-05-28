FROM jekyll/jekyll:stable

EXPOSE 4000
CMD bundle exec jekyll serve --host 0.0.0.0 --watch

WORKDIR /opt/ct
USER root
COPY ./Gemfile ./Gemfile.lock ./
RUN bundle update
RUN bundle install
