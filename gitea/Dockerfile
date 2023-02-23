# pulling offical image
FROM gitea/gitea:1

COPY app.ini /data/gitea/conf/app.ini
RUN mkdir /data/gitea/templates/
COPY home.tmpl /data/gitea/templates/home.tmpl

COPY gitea.tooling.provider.test.pem /data/gitea/gitea.tooling.provider.test.pem
RUN mkdir /home/git
RUN chown git:git /home/git
COPY --chmod=0600 --chown=git:git gitea.tooling.provider.test.pem /home/git/.postgresql/postgresql.key

COPY gitea.tooling.provider.test.crt /data/gitea/gitea.tooling.provider.test.crt
COPY --chmod=0644 --chown=git:git gitea.tooling.provider.test.crt /home/git/.postgresql/postgresql.crt

COPY ca.crt /home/git/.postgresql/root.crt
