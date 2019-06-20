# Spigot

A test telnet server for [Grapevine](https://grapevine.haus/)'s web client.

## Docker

```bash
docker build --build-arg cookie=cookie -t oestrich/spigot:master .
docker run --rm -p 4444:4444 --name spigot -t oestrich/spigot:master
```
