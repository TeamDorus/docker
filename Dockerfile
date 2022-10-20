FROM alpine:3.10

RUN apk --no-cache add bash curl jq dcron libcap tzdata nmap python2 py2-pip && \
    pip install xmltodict && \
    mkdir -p /hostscanner

#RUN addgroup -S foo && adduser -S foo -G foo && \
#    chown foo:foo /usr/sbin/crond && \
#    setcap cap_setgid=ep /usr/sbin/crond

ADD ./entrypoint.sh /opt/entrypoint.sh
ADD ./hostscanner.sh /opt/hostscanner.sh
ADD ./xml2json.py /opt/xml2json.py
RUN chmod a+wx /opt/hostscanner.sh /opt/entrypoint.sh 

#USER foo

WORKDIR /hostscanner
ADD ./telegraf.ip /hostscanner/telegraf.ip

ENTRYPOINT /opt/entrypoint.sh

