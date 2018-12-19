#!/bin/bash

FLAGS="-Djava.net.preferIPv4Stack=true -Xms256m -Xmx256m -jar ArmA3Sync.jar"

if [ ! -z "${ARMA3SYNC_NAME}" ] && [ ! -f "/data/${ARMA3SYNC_NAME}.a3s.repository" ]; then

    echo Initializing repository : ${ARMA3SYNC_NAME}
    ./mkrepo.sh | java ${FLAGS} -console
    echo Repository initialization complete !

fi

java ${FLAGS} ${@:--console}