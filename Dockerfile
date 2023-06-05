ARG BUILD_REPO="https://github.com/komodoplatform/komodo"
ARG BUILD_COMMIT=""
ARG BUILD_DAEMON="komodod"
ARG BUILD_CLI="komodo-cli"
ARG BUILD_THREADS=""
ARG PARAMS_SCRIPT="fetch-params-alt.sh"

# Build stage
FROM ubuntu:22.04 as builder

ARG BUILD_REPO
ARG BUILD_COMMIT
ARG BUILD_THREADS

RUN apt-get -y update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
        build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool libncurses-dev unzip git python3 zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler libqrencode-dev libdb++-dev ntp ntpdate nano software-properties-common curl libevent-dev libcurl4-gnutls-dev cmake clang libsodium-dev liblz4-dev libbrotli-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /

RUN git clone ${BUILD_REPO} build_dir && \
    cd build_dir && \
    if [ ! -z "${BUILD_COMMIT}" ]; then \
        git checkout ${BUILD_COMMIT}; \
    fi && \
    if [ -z "${BUILD_THREADS}" ]; then \
        ./zcutil/build.sh -j$(nproc); \
    else \
        ./zcutil/build.sh -j${BUILD_THREADS}; \
    fi

# Output
FROM ubuntu:22.04
LABEL maintainer="https://github.com/webworker01"

ARG BUILD_DAEMON
ARG BUILD_CLI
ARG PARAMS_SCRIPT

ENV USERNAME="komodo"
ENV PUID=1000
ENV PGID=1000
ENV DAEMON=${BUILD_DAEMON}
ENV PARAMS="-printtoconsole"
ENV USER=${USERNAME}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
        libbrotli-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -g ${PGID} ${USERNAME} && \
    useradd --uid ${PUID} --gid ${PGID} -m ${USERNAME} && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} --chmod=700 entrypoint.sh /home/komodo/entrypoint.sh

COPY --from=builder /build_dir/src/${BUILD_DAEMON} /usr/local/bin/${BUILD_DAEMON}
COPY --from=builder /build_dir/src/${BUILD_CLI} /usr/local/bin/${BUILD_CLI}
COPY --from=builder --chown=${USERNAME}:${USERNAME} --chmod=700 /build_dir/zcutil/${PARAMS_SCRIPT} /home/${USERNAME}/fetch-params.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENTRYPOINT /home/${USERNAME}/entrypoint.sh
