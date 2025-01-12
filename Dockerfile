# Use the official Elixir image from the Docker Hub as the base image
FROM elixir:1.14-alpine AS build

# Install dependencies required to build Phoenix
RUN apk add --no-cache build-base git nodejs npm

# Set the working directory inside the container
WORKDIR /app

# Copy the mix.exs and mix.lock files to cache dependencies
COPY mix.exs mix.lock ./

# Fetch and install Elixir dependencies
RUN mix deps.get

# Copy the rest of the application files to the container
COPY . .

# Install assets (webpack / js / css)
RUN mix assets.deploy

# Compile the application
RUN mix compile

# The second stage of the Docker build will build the actual application image
FROM elixir:1.14-alpine AS app

# Set the working directory inside the container
WORKDIR /app

# Copy the compiled code from the build stage
COPY --from=build /app /app

# Set environment variables for production
ENV MIX_ENV=prod
ENV PORT=4000

# Expose the port Phoenix will run on
EXPOSE 4000

# Command to run the Phoenix server when the container starts
CMD ["mix", "phx.server"]
