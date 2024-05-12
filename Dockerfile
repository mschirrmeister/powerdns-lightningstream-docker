FROM golang:1.22-bookworm as builder

ENV APP_USER app
ENV APP_HOME /app
RUN mkdir -p $APP_HOME/build
WORKDIR $APP_HOME/build
ENV GOBIN $APP_HOME

ARG TARGETOS
ARG TARGETARCH

# https://stackoverflow.com/questions/36279253/go-compiled-binary-wont-run-in-an-alpine-docker-container-on-ubuntu-host/36308464#36308464
ARG CGO_ENABLED=1
ARG GOFLAGS

# tag
RUN git clone --depth 1 -b v0.4.3 https://github.com/PowerDNS/lightningstream.git .

# specific commit
# RUN git clone https://github.com/PowerDNS/lightningstream.git . \
#     && git checkout a2417440c1e3c0fb3f985c29763715de3a61769c \
#     && git reset --hard

COPY start.sh $APP_HOME/

RUN go mod download \
  && go install ./cmd/...


WORKDIR $APP_HOME

RUN rm -rf build

FROM alpine:3.19.1

ENV APP_USER app
ENV APP_HOME /app
WORKDIR $APP_HOME

ENV LOCAL_PORT 8500

COPY --chown=0:0 --from=builder $APP_HOME/lightningstream $APP_HOME/
COPY --chown=0:0 --from=builder $APP_HOME/start.sh $APP_HOME/

RUN apk add --no-cache libc6-compat bind-tools

EXPOSE $LOCAL_PORT/tcp $LOCAL_PORT/udp

# ENTRYPOINT [ "/app/lightningstream" ]
CMD [ "/app/lightningstream", "--config", "/app/lightningstream.yaml", "--minimum-pid", "200", "sync" ]

