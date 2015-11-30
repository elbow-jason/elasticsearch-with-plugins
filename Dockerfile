FROM		java:8-jre
MAINTAINER	Jason Goldberger <jgoldberger@leaf.ag>

RUN		apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4

ENV		ELASTICSEARCH_MAJOR 2.1
ENV 		ELASTICSEARCH_VERSION 2.1.0
ENV		ELASTICSEARCH_REPO_BASE http://packages.elasticsearch.org/elasticsearch/2.x/debian

RUN		 echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch.list

RUN               set -x \
	             && apt-get update \
                     && apt-get install -y --no-install-recommends elasticsearch=$ELASTICSEARCH_VERSION \
		     && rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH

RUN set -ex \
	&& for path in \
		/usr/share/elasticsearch/data \
		/usr/share/elasticsearch/logs \
		/usr/share/elasticsearch/config \
		/usr/share/elasticsearch/config/scripts \
	; do \
		mkdir -p "$path"; \
		chown -R elasticsearch:elasticsearch "$path"; \
	done

COPY config /usr/share/elasticsearch/config
# VOLUME /usr/share/elasticsearch/data # readd this once container is working

ENV ES_HOME /usr/share/elasticsearch

RUN $ES_HOME/bin/plugin install license
RUN $ES_HOME/bin/plugin install shield
RUN mkdir /usr/share/elasticsearch/config/shield


# RUN chown elasticsearch:elasticsearch /etc/elasticsearch/shield/users
# RUN chmod 777 /etc/elasticsearch/shield/users


# RUN ln -s /etc/elasticsearch/shield/users /usr/share/elasticsearch/config/shield/users
# RUN $ES_HOME/bin/shield/esusers useradd elbowjason -r admin -p elbowjason

EXPOSE 9200 9300
USER elasticsearch
CMD ["elasticsearch"]
