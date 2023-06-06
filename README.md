# kmdocker

Containerization of any komodod based project.

This repo builds images and pushes to docker hub. See: https://hub.docker.com/r/webworker01/kmdocker/tags

You can create a docker compose to run a daemon like this:

```
services:
  mortyd:
    container_name: mortyd
    image: webworker01/kmdocker:latest
    environment:
      PARAMS: -printtoconsole -ac_name=MORTY -ac_supply=90000000000 -ac_reward=100000000 -ac_cc=3 -ac_staked=10
      COIN: MORTY
    volumes:
      - /home/USERNAME/.komodo/MORTY:/home/komodo/.komodo/MORTY
      - /home/USERNAME/.zcash-params:/home/komodo/.zcash-params
```

```
services:
  pirated:
    container_name: pirated
    image: webworker01/kmdocker:pirated-latest
    environment:
      DAEMON: pirated
      PARAMS: -printtoconsole
      USER: komodo
    ports:
      - '45452:45452'
      - '45453:45453'
    volumes:
      - /home/USERNAME/.komodo/PIRATE:/home/komodo/.komodo/PIRATE
      - /home/USERNAME/.zcash-params:/home/komodo/.zcash-params
```

This will create a non-root container with the coin daemon running on UID/GID 1000 by default.  If your UID/GID are different, set the PUID and PGID args to the user on your host system as env vars if you wish for the blockchain files to be owned by your user.
