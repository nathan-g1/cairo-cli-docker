FROM rust:1.67-alpine AS builder

COPY script.sh /script.sh

# Install cairo1 compiler
RUN apk add git bash --no-cache musl-dev && \
    git clone https://github.com/starkware-libs/cairo.git && \
    cd cairo && \
    rustup toolchain install nightly-2022-11-03-aarch64-unknown-linux-musl && \
    rustup component add rustfmt --toolchain nightly-2022-11-03-aarch64-unknown-linux-musl && \
    git config --global http.postBuffer 524288000 && \
    chmod 755 /script.sh && \
    bash /script.sh && \
    cargo test && \
    cargo build --release && \
    strip target/release/starknet-compile && \
    cd ..

COPY --from=builder /cairo/target/release/starknet-compile /usr/local/bin/

COPY --from=builder /cairo/target/release/starknet-sierra-compile /usr/local/bin/

# Install cairo-lang
FROM python:3.9.13-alpine3.16 as stage

COPY requirements.txt .

RUN apk add gmp-dev g++ gcc

ARG CAIRO_VERSION

ARG OZ_VERSION

RUN pip wheel --no-cache-dir --no-deps\
    --wheel-dir /wheels\
    -r requirements.txt\
    cairo-lang==$CAIRO_VERSION openzeppelin-cairo-contracts==$OZ_VERSION

FROM python:3.9.13-alpine3.16

RUN apk add --no-cache libgmpxx

COPY --from=stage /wheels /wheels

RUN pip install --no-cache /wheels/*

RUN rm -rf /wheels
