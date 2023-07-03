#!/bin/bash
# setup and hand over control to rootless user
# @author webworker01

if [[ $USERNAME == "root" || $PUID == "0" ]]; then
    HOMEDIR="/root"
else
    HOMEDIR="/home/${USERNAME}"
    groupadd -g ${PGID} ${USERNAME}
    useradd --uid ${PUID} --gid ${PGID} -s /bin/bash ${USERNAME}
fi

cp /usr/local/bin/entrypoint-user.sh ${HOMEDIR}/entrypoint-user.sh
cp /usr/local/bin/fetch-params.sh ${HOMEDIR}/fetch-params.sh

if [[ ! $USERNAME == "root" ]]; then
    chown -R ${USERNAME}:${USERNAME} ${HOMEDIR}

    exec gosu ${USERNAME} ${HOMEDIR}/entrypoint-user.sh
else
    ${HOMEDIR}/entrypoint-user.sh
fi
