FROM alpine:3.20
RUN apk add --no-cache postgresql16-client bash
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
