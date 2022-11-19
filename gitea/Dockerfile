# pulling offical image
FROM gitea/gitea:1

COPY app.ini /data/gitea/conf/app.ini
RUN mkdir /data/gitea/templates/
COPY home.tmpl /data/gitea/templates/home.tmpl
COPY signin_inner.tmpl /data/gitea/templates/user/auth/signin_inner.tmpl

COPY gitea.tooling.provider.test.key /data/gitea/gitea.tooling.provider.test.key
RUN mkdir /home/git
RUN chown git:git /home/git
COPY --chmod=0600 --chown=git:git gitea.tooling.provider.test.key /home/git/.postgresql/postgresql.key

COPY gitea.tooling.provider.test.pem /data/gitea/gitea.tooling.provider.test.pem
COPY --chmod=0644 --chown=git:git gitea.tooling.provider.test.pem /home/git/.postgresql/postgresql.crt

COPY ca.crt /home/git/.postgresql/root.crt
