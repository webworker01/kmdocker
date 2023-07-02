#!/bin/bash
# setup and hand over control to rootless user
# @author webworker01

if [[ $USERNAME == "root" || $PUID == "0" ]]; then
    HOMEDIR=""
else
    HOMEDIR="/home"
    groupadd -g ${PGID} ${USERNAME}
    useradd --uid ${PUID} --gid ${PGID} -s /bin/bash ${USERNAME}
fi

cp /usr/local/bin/entrypoint-user.sh ${HOMEDIR}/${USERNAME}/entrypoint-user.sh
cp /usr/local/bin/fetch-params.sh ${HOMEDIR}/${USERNAME}/fetch-params.sh

if [[ ! $USERNAME == "root" ]]; then
    chown -R ${USERNAME}:${USERNAME} ${HOMEDIR}/${USERNAME}

    exec gosu ${USERNAME} ${HOMEDIR}/${USERNAME}/entrypoint-user.sh
else
    ${HOMEDIR}/${USERNAME}/entrypoint-user.sh
fi
