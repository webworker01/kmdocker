# kmdocker

Containerization of any komodod based project.

This implementation is left purposefully abstracted, you will need to add arguments to run the correct chain you desire.

Edit the `docker-compose.yml` or create a `docker-compose.override.yml` and modify the paths for the volumes to your host filesystem name or if you wish you could use docker volumes like:

```
services:
  komodod:
    volumes:
      - ./entrypoint.sh:/home/komodo/entrypoint.sh
      - komododata/:/home/komodo/.komodo/
      - zcashparams:/home/komodo/.zcash-params

volumes:
  komododata:
  zcashparams:
```

This will create a non-root container with the coin daemon running on UID/GID 1000 by default.  If your UID/GID are different, set the PUID and PGID args to the user on your host system if you wish for the blockchain files to be owned by your user.

