ARG EMSCRIPTEN_VERSION=1.38.26
ARG EMSCRIPTEN_ARCH=64bit

FROM trzeci/emscripten:sdk-tag-${EMSCRIPTEN_VERSION}-${EMSCRIPTEN_ARCH}

RUN echo "Installing build tools..." \
&& apt-get update \
&& apt-get install -y autoconf libtool \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /dist /src
COPY ./build.sh /src
RUN chmod +x  /src/build.sh

ENTRYPOINT [ "./build.sh" ]
CMD [ "--help" ]
