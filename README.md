# Jobot

An IRC bot written in Janet.

## Setup

```sh
make config  # creates config.jdn from example
# Edit config.jdn with your IRC server, nickname, and API keys
make run
```

## Commands

- `echo <message>` — repeat a message back
- `image <query>` — search Google Images
- `news` — random headline
- `random <query>` — search the message log
- `weather` — current weather for configured cities

## Deployment

```sh
make install  # install systemd service
make start    # start the bot
make status   # check if running
```

## License

AGPL-3.0
