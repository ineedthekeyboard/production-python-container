# This is the base docker image for the "proper" setup of a production container that is running python and/or nginx
# In this setup we use Nginx + Gunicorn to server our static assets and python api's respectively.
# I have also included a dummy template to demostrate how to setup a run at boot DB script
FROM phusion/baseimage:bionic-1.0.0

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
#CMD ["/sbin/my_init", "--skip-startup-files"]

#Copy configs
RUN mkdir /loki /promtail
COPY config/loki-config.yaml /loki/loki-config.yaml
COPY config/promtail-config.yaml /promtail/promtail-config.yaml

#Install loki & promtail
RUN apt-get update && apt-get -y install unzip \

    && cd /loki && curl -O -L "https://github.com/grafana/loki/releases/download/v2.0.0/loki-linux-amd64.zip" \
    && unzip "loki-linux-amd64.zip" \
    && chmod a+x "loki-linux-amd64" && rm -rf "loki-linux-amd64.zip" \

    && cd /promtail && curl -O -L "https://github.com/grafana/loki/releases/download/v2.0.0/promtail-linux-amd64.zip" \
    && unzip "promtail-linux-amd64.zip" \
    && chmod a+x "promtail-linux-amd64" && rm -rf "promtail-linux-amd64.zip" \

    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Loki startup service
RUN mkdir /etc/service/loki
COPY config/startup-scripts/loki.sh /etc/service/loki/run
RUN chmod +x /etc/service/loki/run

#Promtail startup service
RUN mkdir /etc/service/promtail
COPY config/startup-scripts/promtail.sh /etc/service/promtail/run
RUN chmod +x /etc/service/promtail/run

