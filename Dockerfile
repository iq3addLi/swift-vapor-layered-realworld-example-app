# -----------------
# Build stage container
# -----------------
FROM swift:5.4.2 as builder

ARG env
WORKDIR /app

# Copy from host to build container
COPY . .

# Build to application
RUN swift build -c release

# Make delivery location
RUN mkdir -p /build/bin

# Replace application binary
RUN mv `swift build -c release --show-bin-path`/realworld /build/bin

# -----------------
# Container for execute
# -----------------
FROM swift:5.4.2-slim

ARG env
WORKDIR /app

# Copy the realworld
COPY --from=builder /build/bin/realworld .

# Set env
ENV ENVIRONMENT='docker'

# Entry
ENTRYPOINT ./realworld serve --env $ENVIRONMENT --hostname 0.0.0.0 --port 80
