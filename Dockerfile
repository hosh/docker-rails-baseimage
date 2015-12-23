# Based on https://github.com/phusion/passenger-docker#getting-started
# https://github.com/phusion/passenger-docker/blob/master/Changelog.md#0918-release-date-2015-12-08
FROM phusion/passenger-ruby22:0.9.18

CMD ["/sbin/my_init"]
EXPOSE 80

ENV RAILS_ENV=production
WORKDIR ${APP_ROOT}

RUN rm -f /etc/nginx/sites-enabled/default \
    && touch /etc/service/nginx/down \
    && mkdir /etc/secrets \
    && touch /etc/secrets/app-env.yml
ADD etc/my_init.d/* /etc/my_init.d/
ADD tools /home/app/tools
ADD rc.local /etc/rc.local
ADD etc/nginx /etc/nginx

ADD etc/*yml ${APP_ROOT}/config/
ADD *.runit /home/app/srv/
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
