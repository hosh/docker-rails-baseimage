# Based on https://github.com/phusion/passenger-docker#getting-started
# https://github.com/phusion/passenger-docker/blob/master/Changelog.md#0917-release-date-2015-08-04
FROM phusion/passenger-ruby22:0.9.17

CMD ["/sbin/my_init"]
EXPOSE 80

ENV RAILS_ENV=production
ENV RUBYGEMS_PROXY_URL=http://rubygems-proxy
ENV APP_ROOT=/home/app/alt-text
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

ADD build/alt-text/ ${APP_ROOT}
RUN cp ${APP_ROOT}/config/app.yml.example ${APP_ROOT}/config/app.yml \
    && chown -R app:app ${APP_ROOT}
ADD .cache/bundle ${APP_ROOT}/vendor/bundle

