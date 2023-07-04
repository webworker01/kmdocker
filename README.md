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
      PUID: 1001
      PGID: 1001
    ports:
      - '45452:45452'
      - '127.0.0.1:45453:45453'
    volumes:
      - /home/USERNAME/.komodo/PIRATE:/home/komodo/.komodo/PIRATE
      - /home/USERNAME/.zcash-params:/home/komodo/.zcash-params
```

This will create a non-root container with the coin daemon running on UID/GID 1000 by default.

If your UID/GID are different, set the PUID and PGID args to the user on your host system as env vars if you wish for the blockchain files to be owned by your user.

If the local directories mapped as volumes do not exist already they might be owned by root and should be safe to chown to your user as long as it matches your PUID / PGID you set earlier

If you have rootless docker installed and want the data files to be owned by the user on your host, please take a look at this example:
```
services:
  komodod:
    container_name: komodod
    image: webworker01/kmdocker:latest
    environment:
      USERNAME: root
      PUID: 0
      PGID: 0
      COIN: KMD
    ports:
      - '7770:7770'
      - '127.0.0.1:7771:7771'
    volumes:
      - /home/USERNAME/.komodo:/root/.komodo
      - /home/USERNAME/.zcash-params:/root/.zcash-params
```
[Rootless docker](https://docs.docker.com/engine/security/rootless/) maps root in the container to your user on the host. Other UIDs will be mapped to subuids under your user.
