#!/bin/bash
# setup and hand over control to rootless user

groupadd -g ${PGID} ${USERNAME}
useradd --uid ${PUID} --gid ${PGID} -s /bin/bash ${USERNAME}

cp /usr/local/bin/entrypoint-user.sh /home/${USERNAME}/entrypoint-user.sh
cp /usr/local/bin/fetch-params.sh /home/${USERNAME}/fetch-params.sh

chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

exec gosu ${USERNAME} /home/${USERNAME}/entrypoint-user.sh
