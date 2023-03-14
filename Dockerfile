FROM python:3.9.13-alpine3.16 as builder

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

COPY --from=builder /wheels /wheels

RUN pip install --no-cache /wheels/*

RUN rm -rf /wheels

FROM rust:1.67-alpine

# Install cairo1 compiler
RUN apk add git bash --no-cache musl-dev && \
    git clone https://github.com/starkware-libs/cairo.git

RUN rustup override set stable && \
    rustup component add rustfmt --toolchain nightly-2022-11-03-aarch64-unknown-linux-musl && \
    rustup update

WORKDIR /cairo

COPY script.sh /cairo/script.sh

RUN chmod 755 /cairo/script.sh && bash /cairo/script.sh

RUN git config --global http.postBuffer 524288000

RUN cargo test
