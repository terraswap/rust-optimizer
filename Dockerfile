# Usage
FROM trzeci/emscripten:1.38.47

# Note: I tried slim and had issues compiling wasm-pack, even with --features vendored-openssl
FROM rust:1.38.0

# setup rust with wasm-pack
RUN rustup target add wasm32-unknown-unknown

# I'd rather not
# RUN cargo install wasm-pack --version 0.8.1
RUN curl -L -sSf https://github.com/rustwasm/wasm-pack/releases/download/v0.8.1/wasm-pack-v0.8.1-x86_64-unknown-linux-musl.tar.gz > wasm-pack-v0.8.1.tar.gz
RUN tar xzf wasm-pack-v0.8.1.tar.gz
RUN cp wasm-pack-v0.8.1-x86_64-unknown-linux-musl/wasm-pack /usr/local/bin

# and pre-install wasm-bindgen cli to avoid issues later
RUN curl -L -sSf https://github.com/rustwasm/wasm-bindgen/releases/download/0.2.53/wasm-bindgen-0.2.53-x86_64-unknown-linux-musl.tar.gz > wasm-bindgen.tar.gz
RUN tar xzf wasm-bindgen.tar.gz
RUN cp wasm-bindgen-0.2.53-x86_64-unknown-linux-musl/wasm-bindgen /usr/local/bin

# cleanup
RUN rm -rf wasm-*

# Precache all cosmwasm dependencies, so we don't redownload everytime
# We will have to download contract-specific ones, but it should be a nice speed-up
# TODO: this didn't seem to have much effect... test this assumption
#RUN cargo install cosmwasm --version 0.4.1 || true
RUN chmod -R 777 /usr/local/cargo

# copy wasm-opt into our path
COPY --from=0 /emsdk_portable/binaryen/bin/wasm-opt /usr/local/bin

# Assume we mount the source code in /code
WORKDIR /code

# Add out script as entry point
ADD optimize.sh /opt/optimize.sh
RUN chmod +x /opt/optimize.sh

CMD ["/opt/optimize.sh"]