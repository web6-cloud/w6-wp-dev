ARG WORDPRESS_VERSION=latest
ARG APP_ALIAS=wp
FROM wordpress:${WORDPRESS_VERSION}

LABEL maintainer="WEB6 <contact@web6.fr>"

ENV WP_CONTENT="/var/www/html/wp-content"

##################################################
#
# User file permissions
#
##################################################
RUN usermod -u 1000 www-data

##################################################
#
# Volumes
#
##################################################
VOLUME ["${WP_CONTENT}/plugins/w6-wp-framework", "${WP_CONTENT}/themes/w6-wp-theme", "${WP_CONTENT}/plugins/${APP_ALIAS}", "${WP_CONTENT}/themes/${APP_ALIAS}"]

##################################################
#
# Port
#
##################################################
EXPOSE 80