FROM elixir:1.8-alpine as builder
WORKDIR /app
ENV MIX_ENV=prod
RUN apk add --no-cache \
    gcc \
    git \
    make \
    musl-dev
RUN mix local.rebar --force && mix local.hex --force
COPY mix.* /app/
RUN mix deps.get --only prod
RUN mix deps.compile

FROM builder as releaser
ARG cookie
ENV COOKIE=${cookie}
WORKDIR /app
COPY . /app/
RUN mix release --env=prod --no-tar

FROM alpine:3.9
ENV LANG=C.UTF-8
RUN apk add -U bash openssl
WORKDIR /app
COPY --from=releaser /app/_build/prod/rel/spigot /app/
COPY config/prod.docker.exs /etc/spigot.config.exs
EXPOSE 4444
ENTRYPOINT ["bin/spigot"]
CMD ["foreground"]
