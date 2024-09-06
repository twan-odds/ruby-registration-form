FROM ruby:3.3.1-alpine AS build
WORKDIR /myapp

# Set environment variables
ENV RAILS_ENV=production

# Install necessary packages to build gems and assets
RUN apk add --no-cache \
    build-base \
    git \
    sqlite-dev \
    tzdata \
    gcompat

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .


# Precompile assets
RUN SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rake assets:precompile

# Setup the database
RUN SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rails db:create db:schema:load

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