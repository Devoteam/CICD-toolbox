# pulling offical image
#FROM gitea/gitea:latest
FROM gitea/gitea:dev

COPY app.ini /data/gitea/conf/app.ini

RUN mkdir /data/gitea/templates
COPY home.tmpl /data/gitea/templates/home.tmpl
#RUN chown git:git -R /data/gitea/templates
