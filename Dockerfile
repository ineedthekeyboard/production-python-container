# This is the base docker image for the "proper" setup of a production container that is running python and/or nginx
# In this setup we use Nginx + Passenger(standalone) to server our static assets and python api's respectively.
# I have also included a dummy template to demostrate how to setup a run at boot DB script
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

# Install passenger
RUN apt-get install -y dirmngr gnupg && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    apt-get install -y apt-transport-https ca-certificates && \
    # Add our APT repository
    sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main > /etc/apt/sources.list.d/passenger.list' && \
    apt-get update && \
    # Install Passenger
    apt-get install -y passenger && \
    /usr/bin/passenger-config validate-install && \
    adduser app

# Setup fs for app
RUN mkdir /app && mkdir /app/webapp && \
    chown app: /app/webapp && \
#   mkdir /app/logs && chmod 777 /app/logs && \
    rm -f /etc/nginx/sites-enabled/default && \
#    Removing the syslog startup because it hurts "SOME" app engines that already bind to the same place.(heroku/ DO appengine)
    rm -f /etc/my_init.d/10_syslog-ng.init

#Nginx configs
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/webapp.conf /etc/nginx/sites-enabled/webapp.conf

#Copy static site files
COPY ./static /opt/dashboard

#Setup NGINX runscript to be run in when the container starts
RUN mkdir /etc/service/nginx
COPY config/startup-scripts/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

#Setup Passenger runscript to be run in when the container starts
COPY config/Passengerfile.json /app/webapp/Passengerfile.json
COPY config/passenger_wsgi.py /app/webapp/passenger_wsgi.py
RUN mkdir /etc/service/passenger
COPY config/startup-scripts/passenger.sh /etc/service/passenger/run
RUN chmod +x /etc/service/passenger/run

#Setup startup db updater to NOT run in the background but only run once when the container is started.
RUN mkdir -p /etc/my_init.d
COPY config/startup-scripts/db_updater_fake.sh /etc/my_init.d/db_updater_fake.sh
RUN chmod +x /etc/my_init.d/db_updater_fake.sh

#Setup Python API server
ADD ./requirements.txt /app/webapp/requirements.txt
RUN python3.8 -m pip install -r /app/webapp/requirements.txt
COPY ./src /app/webapp
