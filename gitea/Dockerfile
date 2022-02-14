# pulling offical image
FROM gitea/gitea:latest

COPY app.ini /data/gitea/conf/app.ini
RUN mkdir /data/gitea/templates/
COPY home.tmpl /data/gitea/templates/home.tmpl