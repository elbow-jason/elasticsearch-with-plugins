FROM           ubuntu:15.04
MAINTAINER     Jason Goldberger
ENV            ES_VERSION 2.0.0
ENV            ES_USER_PASSWORD elbowjason

RUN            apt-get update
RUN            apt-get -y install wget
RUN            apt-get -y install openjdk-7-jre

RUN            wget -qO /tmp/es.tgz https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.tar.gz && \
               cd /usr/share && \
               tar xf /tmp/es.tgz && \
               rm /tmp/es.tgz

ENV            ES_HOME /usr/share/elasticsearch-$ES_VERSION
RUN            useradd -d $ES_HOME -M -r elasticsearch && \
               chown -R elasticsearch: $ES_HOME

RUN            mkdir /data /conf && touch /data/.CREATED /conf/.CREATED && chown -R elasticsearch: /data /conf
VOLUME         ["/data","/conf"]

ADD            start /start

WORKDIR        $ES_HOME

RUN            bin/plugin install license
RUN            bin/plugin install shield

USER           elasticsearch

EXPOSE         9200 9300

ENV            OPTS=-Dnetwork.bind_host=_non_loopback_

CMD            ["/start"]