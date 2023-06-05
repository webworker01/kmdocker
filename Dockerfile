ARG USERNAME=komodo
ARG PUID=1000
ARG PGID=1000
ARG REPO="https://github.com/komodoplatform/komodo"
ARG COMMIT=""
ARG BUILD_THREADS=""
ARG DAEMON="komodod"
ARG CLI="komodo-cli"
ARG PARAMS_SCRIPT="fetch-params-alt.sh"

# Build stage
FROM ubuntu:22.04 as builder

ARG REPO
ARG COMMIT
ARG BUILD_THREADS

RUN apt-get -y update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
        build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool libncurses-dev unzip git python3 zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler libqrencode-dev libdb++-dev ntp ntpdate nano software-properties-common curl libevent-dev libcurl4-gnutls-dev cmake clang libsodium-dev liblz4-dev libbrotli-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /komodo

RUN git clone ${REPO} komodo && \
    cd komodo && \
    if [ ! -z "${COMMIT}" ]; then \
        git checkout ${COMMIT}; \
    fi && \
    if [ -z "${BUILD_THREADS}" ]; then \
        ./zcutil/build.sh -j$(nproc); \
    else \
        ./zcutil/build.sh -j${BUILD_THREADS}; \
    fi

# Output
FROM ubuntu:22.04
LABEL maintainer="https://github.com/webworker01"

ARG USERNAME
ARG PUID
ARG PGID
ARG DAEMON
ARG CLI
ARG ZCASHPARAMS

ENV DAEMON="komodod"
ENV PARAMS="-printtoconsole"

RUN groupadd -g ${PGID} ${USERNAME} && \
    useradd --uid ${PUID} --gid ${PGID} -m ${USERNAME} && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} --chmod=700 entrypoint.sh /home/komodo/entrypoint.sh

COPY --from=builder /komodo/komodo/src/${DAEMON} /usr/local/bin/${DAEMON}
COPY --from=builder /komodo/komodo/src/${CLI} /usr/local/bin/${CLI}
COPY --from=builder --chown=${USERNAME}:${USERNAME} --chmod=700 /komodo/komodo/zcutil/${PARAMS_SCRIPT} /home/komodo/fetch-params.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENTRYPOINT /home/komodo/entrypoint.sh
