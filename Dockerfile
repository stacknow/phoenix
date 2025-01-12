# Stage 1: Build
FROM elixir:1.15-alpine AS build

RUN apk add --no-cache build-base git nodejs npm yarn openssl

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

# Debugging step to verify release directory
RUN echo "Contents of /app/_build/prod:" && ls -l /app/_build/prod
RUN echo "Contents of /app/_build/prod/rel:" && ls -l /app/_build/prod/rel

# Stage 2: Release
FROM alpine:latest AS app

RUN apk add --no-cache openssl ncurses-libs bash

ENV MIX_ENV=prod LANG=C.UTF-8
WORKDIR /app

# Use the correct app name in the COPY step
COPY --from=build /app/_build/prod/rel/hello_world ./ 

EXPOSE 4000
CMD ["bin/hello_world", "start"]
