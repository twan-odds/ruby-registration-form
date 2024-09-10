FROM ruby:3.3.1-alpine AS build
WORKDIR /myapp

# Set environment variables
ENV RAILS_ENV=production

# Install necessary packages to build gems and assets
RUN apk add --no-cache \
    build-base \
    git \
    tzdata \
    gcompat \
    nodejs \
    yarn

# Install only necessary gems and remove extensions
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3 && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete


# Copy application code
COPY . .

# Install node modules
RUN yarn install --frozen-lockfile

# Precompile assets and then remove unnecessary files
RUN SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rake assets:precompile && \
    rm -rf node_modules tmp/cache vendor/assets test spec

# Setup the database
# RUN SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rails db:create db:schema:load

FROM ruby:3.3.1-alpine
WORKDIR /myapp

# Install runtime dependencies
RUN apk add --no-cache \
    sqlite-libs \
    tzdata \
    gcompat

# Copy built artifacts from the build stage
COPY --from=build /myapp /myapp/
COPY --from=build /usr/local/bundle /usr/local/bundle

# Set environment variables
ENV RAILS_ENV=production

# Run Docker entrypoint script
ENTRYPOINT ["/myapp/bin/docker-entrypoint"]

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]