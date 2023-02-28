FROM golang:1.19-bullseye AS build
ARG tag_version=v1.5.3

WORKDIR /build
RUN git clone \
        -c advice.detachedHead=false \
        --single-branch \
        --branch ${tag_version} \
        --depth 1 \
        https://github.com/BitCannaGlobal/bcna.git \
        . \
    && make install \
    && bcnad version
WORKDIR /dist
RUN mkdir bitcanna bin \
    && mv $(which bcnad) bin/


FROM gcr.io/distroless/base-debian11:latest

COPY --from=build --chown=nonroot:nonroot /dist/bitcanna /bitcanna
COPY --from=build /dist/bin/bcnad /usr/local/bin/
USER nonroot:nonroot
WORKDIR /bitcanna
ENTRYPOINT ["bcnad", "--home", "."]
