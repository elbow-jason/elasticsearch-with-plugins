FROM            java:8-jre
MAINTAINER      Jason Goldberger <jgoldberger@leaf.ag>

## Install elasticsearch
RUN             apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4

ENV             ELASTICSEARCH_MAJOR     2.1
ENV             ELASTICSEARCH_VERSION   2.1.0
ENV             ELASTICSEARCH_REPO_BASE http://packages.elasticsearch.org/elasticsearch/2.x/debian

RUN             echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch.list

RUN             apt-get update && apt-get install -y --no-install-recommends elasticsearch=$ELASTICSEARCH_VERSION \
                && rm -rf /var/lib/apt/lists/*

ENV             ES_HOME /usr/share/elasticsearch
ENV             PATH    $ES_HOME/bin:$PATH
## !Install elasticsearch

## Setup ES config.
# Add config dir to the Docker image both on /etc and $ES_HOME (elasticsearch and esuser)
COPY            config/          /etc/elasticsearch/
COPY            config/          $ES_HOME/config
COPY            config/roles.yml $ES_HOME/config/shield/roles.yml

# Install shield plugin (license is required).
RUN             $ES_HOME/bin/plugin install license
RUN             $ES_HOME/bin/plugin install shield
# Fix the peromssions
RUN             chown -R elasticsearch:elasticsearch $ES_HOME /etc/elasticsearch/
## !Setup ES Config.

# Declare a volume for persistent data.
VOLUME          /usr/share/elasticsearch/data # readd this once container is working

# Add elbowjason user
RUN             $ES_HOME/bin/shield/esusers useradd elbowjason -r admin -p elbowjason

## Image metadata.
EXPOSE          9200 9300
CMD             chown -R elasticsearch:elasticsearch $ES_HOME && su -s /bin/bash - elasticsearch -c /usr/share/elasticsearch/bin/elasticsearch
