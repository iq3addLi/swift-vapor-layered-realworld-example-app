# -----------------
# Build stage container
# -----------------
FROM swift:5.1.2 as builder

# For local build, add `--build-arg env=docker`
# In your application, you can use `Environment.custom(name: "docker")` to check if you're in this env
ARG env

# apt-get
RUN apt-get -qq update \
  && apt-get -q -y install openssl libssl-dev libz-dev libicu-dev \
  && rm -r /var/lib/apt/lists/*
  
WORKDIR /app

# Copy from host to build container
COPY . .

# Copy shared objects
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so* /build/lib

# Build to application
RUN swift build -c release && mv `swift build -c release --show-bin-path` /build/bin

# -----------------
# Container for execute
# -----------------
FROM ubuntu:18.04

ARG env

# Libraries for swift application
RUN apt -qq update \
  && apt install -y libicu60 libxml2 libbsd0 libcurl4 libatomic1 \
  && rm -r /var/lib/apt/lists/*
  
WORKDIR /app

# Copy the realworld
COPY --from=builder ./build/bin/realworld .

# Copy shared objects
COPY --from=builder /build/lib/* /usr/lib/

ENV ENVIRONMENT='docker'

ENTRYPOINT ./realworld serve --env $ENVIRONMENT --hostname 0.0.0.0 --port 80
