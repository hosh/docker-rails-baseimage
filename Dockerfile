# Based on https://github.com/phusion/passenger-docker#getting-started
# https://github.com/phusion/passenger-docker/blob/master/Changelog.md#0918-release-date-2015-12-08
FROM phusion/passenger-customizable:0.9.18

CMD ["/sbin/my_init"]
EXPOSE 80

ENV RAILS_ENV=production

RUN rm -f /etc/nginx/sites-enabled/default \
    && touch /etc/service/nginx/down \
    && mkdir /etc/secrets \
    && touch /etc/secrets/app-env.yml \
    && mkdir -p /home/app/gems/bin
ADD etc/my_init.d/* /etc/my_init.d/
ADD tools /home/app/tools
ADD etc/rc.local /etc/rc.local
ADD etc/nginx /etc/nginx

ADD runit/*.runit /home/app/srv/


# Install ruby 2.3 and update system
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y ruby-switch ruby2.3 ruby2.3-dev \
  && ruby-switch --set ruby2.3 \
  && apt-get clean  \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# monit is needed if we are running this in Kubernetes
# and we needed to make sure Sidekiq is running
#RUN apt-get update && \
#    apt-get install monit -y && \
#    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#ADD etc/monit/monitrc /etc/monit/monitrc
#RUN chmod 0700 /etc/monit/monitrc

# Make sure erubis is installed so that we can use it to generate
# configuration files
RUN gem install erubis -N -no-update-sources --minimal-deps --conservative -n /home/app/bin -V

#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
