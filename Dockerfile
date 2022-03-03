FROM alpine:latest

RUN apk add --no-cache git

COPY entrypoint.sh /entrypoint.sh

RUN wget https://github.com/qingstor/snips/releases/download/v0.3.6/snips-v0.3.6-linux_amd64.tar.gz  
RUN tar -xvf snips-v0.3.6-linux_amd64.tar.gz
COPY snips /usr/local/bin/snips

ENTRYPOINT ["/entrypoint.sh"]
