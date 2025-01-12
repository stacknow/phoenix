# Stage 1: Build
FROM elixir:1.15-alpine AS build

# Install required packages
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    yarn \
    openssl

# Set environment variables
ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    APP_NAME=my_app

# Create and set the working directory
WORKDIR /app

# Copy and fetch dependencies
COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force && mix deps.get --only prod

# Install and build assets using esbuild
COPY assets/package.json assets/yarn.lock ./assets/
RUN cd assets && yarn install --frozen-lockfile
COPY assets ./assets
RUN mix assets.deploy

# Copy application source code
COPY . .

# Compile and build the release
RUN mix compile
RUN mix release

# Stage 2: Release
FROM alpine:latest AS app

# Install runtime dependencies
RUN apk add --no-cache \
    openssl \
    ncurses-libs \
    bash

# Set environment variables
ENV HOME=/app \
    MIX_ENV=prod \
    LANG=C.UTF-8 \
    APP_NAME=my_app

# Create a directory for the application
WORKDIR /app

# Copy the release from the build stage
COPY --from=build /app/_build/prod/rel/$APP_NAME ./

# Expose the default Phoenix port
EXPOSE 4000

# Command to start the application
CMD ["bin/my_app", "start"]
