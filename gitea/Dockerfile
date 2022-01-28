# pulling offical image
#FROM gitea/gitea:latest
FROM gitea/gitea:1.16.0-rc1

COPY app.ini /data/gitea/conf/app.ini

USER git
RUN mkdir templates
COPY home.tmpl /data/gitea/templates/home.tmpl
