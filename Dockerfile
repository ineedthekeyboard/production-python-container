FROM phusion/baseimage:bionic-1.0.0

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
#CMD ["/sbin/my_init", "--skip-startup-files"]

#Install system libs (python, nginx)
RUN apt-get update && apt-get -y install software-properties-common && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get -y install python3.8 python3-pip nginx \
    && python3.8 -m pip install --upgrade pip && python3.8 --version \
    # Clean up APT when done.
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup fs for app
RUN mkdir /app && mkdir /app/webapp \
#    && mkdir /app/logs && chmod 777 /app/logs
    && rm -f /etc/nginx/sites-enabled/default
#    Removing the syslog startup because it hurts "SOME" app engines (heroku/ DO appengine)
#    && rm -f /etc/my_init.d/10_syslog-ng.init

#Nginx configs
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/webapp.conf /etc/nginx/sites-enabled/webapp.conf

#Copy static site files
COPY ./static /opt/dashboard

#Setup NGINX runscript to be run in when the container starts
RUN mkdir /etc/service/nginx
COPY config/startup-scripts/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

#Setup GUNICORN runscript to be run in when the container starts
RUN mkdir /etc/service/gunicorn
COPY config/startup-scripts/gunicorn.sh /etc/service/gunicorn/run
RUN chmod +x /etc/service/gunicorn/run

#Setup startup db updater to not run in the background but only run once when the container is started.
RUN mkdir -p /etc/my_init.d
COPY config/startup-scripts/db_updater_fake.sh /etc/my_init.d/db_updater_fake.sh
RUN chmod +x /etc/my_init.d/db_updater_fake.sh

#Setup Python API server
ADD ./requirements.txt /app/webapp/requirements.txt
RUN python3.8 -m pip install -r /app/webapp/requirements.txt
COPY ./src /app/webapp
