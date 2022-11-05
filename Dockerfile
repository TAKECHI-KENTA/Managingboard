FROM ruby:2.7.3
RUN apt-get update -qq && apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn
RUN apt-get update -qq && apt-get install -y \
    postgresql-client \
    build-essential \
    libpq-dev \
    node.js \
    yarn \
    vim \
    imagemagick
WORKDIR /managing_board
COPY Gemfile* ./
COPY ./ ./
# RUN gem install bundler:2.1.4
RUN bundle install
# RUN yarn install
# Add a script to be executed every time the container starts.
# #COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3003

# Configure the main process to run when running the image
# CMD ["rails", "server", "-b", "0.0.0.0"]