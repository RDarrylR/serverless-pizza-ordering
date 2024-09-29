ARG BASE_IMAGE=rust:1.81.0-slim-bullseye
ARG APP_NAME=fargate_rust_order_delivery
FROM $BASE_IMAGE as builder
RUN mkdir /app
WORKDIR /app
COPY . .
RUN cargo build --release

FROM $BASE_IMAGE
COPY --from=builder /app/target/release/fargate_rust_order_delivery /
CMD ["/fargate_rust_order_delivery"]