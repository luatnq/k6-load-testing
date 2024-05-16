# FROM --platform=$BUILDPLATFORM golang:1.22-alpine3.19 as builder
# WORKDIR $GOPATH/src/go.k6.io/k6
# ADD . .
# ARG TARGETOS TARGETARCH
# RUN apk --no-cache add git=~2
# RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -o /usr/bin/k6
# RUN go install -trimpath github.com/k6io/xk6/cmd/xk6@latest
# RUN xk6 build --with github.com/avitalique/xk6-file@latest
# RUN cp k6 $GOPATH/bin/k6

FROM golang:1.22-alpine3.19 as builder
WORKDIR $GOPATH/src/go.k6.io/k6
ADD . .
RUN apk --no-cache add build-base git
RUN go install go.k6.io/xk6/cmd/xk6@latest

# 
# 1) Copy the following `--with ...` line, modifying the module name for additional extension(s).
# 2) CGO_ENABLED will ideally be '0' (disabled), but some extensions require it be enabled. (See docs for your extensions)
# add extensions to k6 for influxdb, timescaledb and kafka testing
RUN CGO_ENABLED=0 xk6 build \
    --with github.com/grafana/xk6-output-timescaledb \
    --with github.com/grafana/xk6-output-influxdb \
    --with github.com/mostafa/xk6-kafka@latest \
    --output /usr/bin/k6

# Runtime stage
FROM alpine:3.18 as release

RUN adduser -D -u 12345 -g 12345 k6
COPY --from=builder /usr/bin/k6 /usr/bin/k6

USER k6
WORKDIR /home/k6

ENTRYPOINT ["k6"]

# Browser-enabled bundle
FROM release as with-browser

USER root

COPY --from=release /usr/bin/k6 /usr/bin/k6
RUN apk --no-cache add chromium-swiftshader

USER k6

ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/

ENV K6_BROWSER_HEADLESS=true
# no-sandbox chrome arg is required to run chrome browser in
# alpine and avoids the usage of SYS_ADMIN Docker capability
ENV K6_BROWSER_ARGS=no-sandbox

ENTRYPOINT ["k6"]
