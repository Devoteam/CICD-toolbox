# pulling offical image
FROM gitea/gitea:latest

COPY app.ini /data/gitea/conf/app.ini
RUN mkdir /data/gitea/templates/
COPY home.tmpl /data/gitea/templates/home.tmpl
COPY signin_inner.tmpl /data/gitea/templates/user/auth/signin_inner.tmpl

COPY gitea.tooling.test.key /data/gitea/gitea.tooling.test.key
RUN mkdir /home/git
RUN chown git:git /home/git
COPY --chmod=0600 --chown=git:git gitea.tooling.test.key /home/git/.postgresql/postgresql.key

COPY gitea.tooling.test.pem /data/gitea/gitea.tooling.test.pem
COPY --chmod=0644 --chown=git:git gitea.tooling.test.pem /home/git/.postgresql/postgresql.crt

COPY ca.crt /home/git/.postgresql/root.crt
