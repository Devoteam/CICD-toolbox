FROM netarch/cicdtoolbox:lldap

healthcheck:
    test: 'curl --insecure --head --fail -s https://localhost || exit 1'
    interval: 1m30s
    timeout: 10s
    retries: 3