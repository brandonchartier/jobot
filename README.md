# Jobot

An IRC bot written in Janet.

## Setup

```sh
make setup   # install system dependencies (libcurl, libsqlite3)
make build   # compile the bot
make config  # create config.jdn from example — edit with your settings
make run
```

## Commands

- `echo <message>` — repeat a message back
- `image <query>` — search Google Images
- `news` — random headline
- `random <query>` — search the message log
- `weather` — current weather for configured cities

Any other message directed at the bot gets a Markov chain reply.

## Deployment

```sh
make install  # install systemd service
make start    # start the bot
make status   # check if running
```

## Notes

Jobot uses a single SQLite database for both the message log and the Markov
chain. The Markov model is trained from the message log on first startup and
updated incrementally as new messages arrive. It persists across restarts.

To retrain from scratch, clear the `markov_transitions` and `markov_starts`
tables and restart the bot.

## License

AGPL-3.0
