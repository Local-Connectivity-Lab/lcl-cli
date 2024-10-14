FROM swift:5.10.1-bookworm

RUN apt update \
    apt install build-essential -y

COPY . /tmp/lcl-cli
WORKDIR /tmp/lcl-cli

RUN swift build \
    --static-swift-stdlib \
    -c release

RUN mv .build/release/lcl /lcl
RUN strip /lcl
RUN /lcl --help
RUN ldd /lcl
