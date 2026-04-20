# --- build stage ---
ARG GO_VERSION=1
FROM golang:${GO_VERSION}-bookworm as builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

# build static binary (ลด dependency runtime)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /run-app .

# --- run stage ---
FROM debian:bookworm-slim

# 🔥 สำคัญ: fix TLS
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /run-app .

# optional แต่ดี: บอก port
EXPOSE 8080

CMD ["./run-app"]