FROM alpine:3.14

COPY files/main.sh  /opt/main.sh

RUN apk update && \
    apk add --no-cache python3 py3-pip ca-certificates && \
#    pip3 install s3cmd && \
    pip install https://github.com/s3tools/s3cmd/archive/ee4b303d814d35230ee51d5b04ef51d302d35506.zip && \
    mkdir -p /opt/source && \
    chmod 755 /opt/main.sh

WORKDIR /
CMD ["/opt/main.sh"]
