#!/bin/bash
# setup kmd based daemon in container
# @author webworker01

echo "Current user: $(whoami) $(id)"

cd ${HOME}

./fetch-params.sh

if [[ "${COIN^^}" == "KMD" ]]; then
    path="${HOME}/.komodo"
    file="komodo.conf"
else
    path="${HOME}/.komodo/${COIN^^}"
    file="${COIN^^}.conf"
fi

# Create conf file if not exist
if [[ ! -f ${path}/${file} ]]; then
    randusername=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    randpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

    mkdir -p ${path}

    cat <<EOF > ${path}/${file}
rpcuser=user$randusername
rpcpassword=pass$randpassword
txindex=1
server=1
rpcworkqueue=256
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
EOF

    chmod 600 ${path}/${file}
fi

# Start the daemon
${DAEMON} ${PARAMS}
