#FROM alpine:latest

#RUN apk add --no-cache git

#COPY entrypoint.sh /entrypoint.sh

#ENTRYPOINT ["/entrypoint.sh"]

FROM ubuntu:latest
COPY entrypoint.sh /entrypoint.sh

RUN apt-get update --fix-missing && apt-get install -y fontconfig --fix-missing
RUN  apt-get install -y git
RUN  apt-get install -y wget

RUN wget -O - https://github.com/qingstor/snips/releases/download/v0.3.6/snips-v0.3.6-linux_amd64.tar.gz | tar -C /bin/ -zxf -

RUN pwd
RUN ls -alth


ENTRYPOINT ["/entrypoint.sh"]