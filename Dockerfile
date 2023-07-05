 FROM alpine:3.17
 WORKDIR /cairo
 RUN wget https://github.com/starkware-libs/cairo/releases/download/v2.0.1/release-x86_64-unknown-linux-musl.tar.gz
 RUN tar -xf release-x86_64-unknown-linux-musl.tar.gz
 WORKDIR /cairo/cairo
 RUN ./bin/starknet-compile --version
