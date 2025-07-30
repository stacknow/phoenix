# Stage 1: Build
FROM elixir:1.15-slim AS build

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    nodejs \
    npm \
    && apt-get clean

RUN npm install -g yarn

ENV MIX_ENV=prod LANG=C.UTF-8
WORKDIR /app

COPY mix.exs mix.lock ./
COPY config config
RUN mix local.hex --force && mix local.rebar --force && mix deps.get --only prod

COPY assets assets
RUN cd assets && yarn install --frozen-lockfile

COPY . .
RUN mix assets.deploy
RUN mix compile
RUN mix release

# Debug to verify the release directory
RUN echo "Contents of /app/_build/prod/rel/hello_world:" && ls -l /app/_build/prod/rel/hello_world

# Stage 2: Release
FROM debian:bookworm-slim AS app

RUN apt-get update && apt-get install -y \
    bash \
    openssl \
    libncurses5 \
    libncursesw5 \
    libstdc++6 \
    libsystemd0 \
    && apt-get clean

ENV MIX_ENV=prod LANG=C.UTF-8
WORKDIR /app

COPY --from=build /app/_build/prod/rel/hello_world ./

EXPOSE 4000
CMD ["bin/hello_world", "start"]
