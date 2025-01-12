FROM elixir:1.14-alpine AS build

# Install dependencies
RUN apk add --no-cache build-base git nodejs npm

# Install Hex (Elixir's package manager)
RUN mix local.hex --force

# Set the working directory
WORKDIR /app

# Copy the mix files
COPY mix.exs mix.lock ./

# Install the dependencies
RUN mix deps.get

# Expose the Phoenix application port
EXPOSE 4000

# Copy the rest of the application files
COPY . .

# Set the command to run the Phoenix app
CMD ["mix", "phx.server"]
