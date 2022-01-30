# pulling offical image
#FROM gitea/gitea:latest
FROM gitea/gitea:1.16.0-rc1

COPY app.ini /data/gitea/conf/app.ini

RUN mkdir /data/gitea/templates
COPY home.tmpl /data/gitea/templates/home.tmpl
#RUN chown git:git -R /data/gitea/templates
