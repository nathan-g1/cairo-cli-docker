#!/usr/bin/env bash
printf "
[net]
git-fetch-with-cli = true
" >> /usr/local/cargo/config

printf '
[url "git@github.com:"]
        insteadOf = "https://github.com/"

[url "https://github.com/rust-lang/crates.io-index"]
        insteadOf = "https://github.com/rust-lang/crates.io-index"
' >> /root/.gitconfig
