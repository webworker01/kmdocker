#!/bin/bash

cd ${HOME}/komodo
./zcutil/fetch-params-alt.sh

${HOME}/komodo/src/${DAEMON} ${PARAMS}
