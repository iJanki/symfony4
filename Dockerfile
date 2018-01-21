FROM ijanki/php71-base

MAINTAINER Daniele Cesarini <daniele.cesarini@gmail.com>

ENV fpm_conf /etc/php7/php-fpm.d/www.conf

RUN	apk update && \
    apk add --update \
    nginx \
    php7-fpm && \
	sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf && \
	sed -i "s|;*error_log\s*=\s*log/php7/error.log|error_log = /proc/self/fd/2|g" /etc/php7/php-fpm.conf && \
	sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" ${fpm_conf} && \
	sed -i "s|;*listen\s*=\s*/||g" ${fpm_conf} && \
	sed -i "s|;*clear_env\s*=\s*no|clear_env = no|g" ${fpm_conf} && \
	sed -i "s|;*user\s*=\s*nobody|user = nginx|g" ${fpm_conf} && \
	sed -i "s|;*group\s*=\s*nobody|group = nginx|g" ${fpm_conf} && \
	sed -i "s|;*catch_workers_output\s*=\s*yes|catch_workers_output = yes|g" ${fpm_conf} && \
    mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    mkdir -p /run/nginx && \
    # Cleaning up
    mkdir -p /www && \
    chown nginx:nginx /www && \
    apk del tzdata curl && \
    rm -rf /var/cache/apk/*

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

WORKDIR /www

EXPOSE 80

ONBUILD COPY . /www
ONBUILD RUN chown -R nginx:nginx /www

ADD conf/nginxsupervisor.conf /etc/supervisor.d/nginx.ini
ADD conf/phpfpm.conf /etc/supervisor.d/phpfpm.ini
