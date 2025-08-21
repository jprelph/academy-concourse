FROM alpine:latest

RUN apk update \
 && apk add bash curl
 && apk add nginx

CMD ["bash"]
