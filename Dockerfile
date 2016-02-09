# Используем за основу контейнера Ubuntu 14.04 LTS
FROM ubuntu:14.04
# Переключаем Ubuntu в неинтерактивный режим — чтобы избежать лишних запросов
ENV DEBIAN_FRONTEND noninteractive 
# Устанавливаем локаль
RUN locale-gen ru_RU.UTF-8 && dpkg-reconfigure locales 

# Добавляем необходимые репозитарии и устанавливаем пакеты
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget curl php5-fpm php5-mysql php5-gd php5-curl php-pear php-apc php5-mcrypt php5-imagick php5-memcache supervisor nginx

# Удаляем хост по умолчанию
RUN rm -rf /etc/nginx/sites-enabled/default
# Добавляем описание виртуального хоста
ADD www.conf /etc/nginx/sites-available/www
# Активируем виртуальный хост
RUN ln -s /etc/nginx/sites-available/www /etc/nginx/sites-enabled/www
# Отключаем режим демона для Nginx (т.к. запускать будем сами) 
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf 
# Отключаем режим демона для php-fpm
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf 
# Path errors fix
RUN sed -i -e "s/;cgi.fix_pathinfo\s*=\s*1/cgi.fix_pathinfo = 0/g" /etc/php5/fpm/php.ini
# Добавляем конфиг supervisor (описание процессов, которые мы хотим видеть запущенными на этом контейнере)
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 
# Делаем пользователя 1000 в www-data
RUN usermod -u 1000 www-data 

# Запускаем supervisor
CMD ["/usr/bin/supervisord"]
