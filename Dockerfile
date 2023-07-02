ARG BUILD_REPO="https://github.com/komodoplatform/komodo"
ARG BUILD_COMMIT=""
ARG BUILD_DAEMON="komodod"
ARG BUILD_CLI="komodo-cli"
ARG BUILD_THREADS=""
ARG PARAMS_SCRIPT="fetch-params-alt.sh"
ARG BUILD_COIN="KMD"

# Build stage
FROM ubuntu:22.04 as builder

ARG BUILD_REPO
ARG BUILD_COMMIT
ARG BUILD_THREADS

RUN apt-get -y update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
        build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool libncurses-dev unzip git python3 \
        zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler \
        libqrencode-dev libdb++-dev ntp ntpdate nano software-properties-common curl libevent-dev libcurl4-gnutls-dev \
        cmake clang libsodium-dev liblz4-dev libbrotli-dev && \
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
ENV COIN=${BUILD_COIN}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
        ca-certificates curl gosu libbrotli-dev libgomp1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /build_dir/src/${BUILD_DAEMON} /usr/local/bin/${BUILD_DAEMON}
COPY --from=builder /build_dir/src/${BUILD_CLI} /usr/local/bin/${BUILD_CLI}
COPY --from=builder /build_dir/zcutil/${PARAMS_SCRIPT} /usr/local/bin/fetch-params.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY entrypoint-user.sh /usr/local/bin/entrypoint-user.sh

ENTRYPOINT /usr/local/bin/entrypoint.sh
