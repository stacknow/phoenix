# Step 1: Set up the build environment
FROM elixir:1.14-alpine AS build

# Install necessary dependencies
RUN apk update && \
    apk add --no-cache build-base nodejs npm git

# Set the working directory inside the container
WORKDIR /app

# Install Hex package manager
RUN mix local.hex --force

# Copy the mix.exs and mix.lock files first (to leverage caching)
COPY mix.exs mix.lock ./

# Fetch dependencies
RUN mix deps.get

# Copy the rest of the application code
COPY . .

# Compile the application
RUN mix assets.deploy
RUN MIX_ENV=prod mix release

# Step 2: Set up the production environment
FROM elixir:1.14-alpine AS runtime

# Install necessary runtime dependencies
RUN apk add --no-cache libstdc++ ncurses-libs

# Set the working directory
WORKDIR /app

# Copy the built release from the build stage
COPY --from=build /app/_build/prod/rel/phoenix .

# Expose the port that the Phoenix app runs on
EXPOSE 4000

# Run the Phoenix application
CMD ["bin/phoenix", "start"]
