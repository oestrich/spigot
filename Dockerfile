FROM elixir:1.9-alpine as builder
WORKDIR /app
ENV MIX_ENV=prod
RUN apk add --no-cache gcc git make musl-dev
RUN mix local.rebar --force && mix local.hex --force
COPY mix.* /app/
RUN mix deps.get --only prod
RUN mix deps.compile

FROM builder as releaser
WORKDIR /app
ENV MIX_ENV=prod
COPY . /app/
RUN mix release

FROM alpine:3.11
ENV LANG=C.UTF-8
RUN apk add -U bash openssl
WORKDIR /app
COPY --from=releaser /app/_build/prod/rel/spigot /app/
EXPOSE 4443
EXPOSE 4444
ENTRYPOINT ["bin/spigot"]
CMD ["start"]
