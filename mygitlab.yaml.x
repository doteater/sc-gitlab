apiVersion: apps.gitlab.com/v1beta1
kind: GitLab
metadata:
  name: gitlab
  namespace: gitlab-system
spec:
  chart:
    version: "8.2.2" # https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/blob/<OPERATOR_VERSION>/CHART_VERSIONS
    values:
      global:
        #removeme, debugging cert
        certificates:
          customCAs:
            - secret: secret-custom-ca
        appConfig:
          omniauth:
            enabled: true
            allowSingleSignOn: ['openid_connect']
            #allowSingleSignOn: ['oauth2_generic']
            #allowSignleSignOn: ['zoho']
            blockAutoCreatedUsers: false
            providers:
              #- secret: gitlab-oauth2-generic
              - secret: gitlab-openid
        hosts:
          domain: sentracam.net # use a real domain here
          externalIP: 10.9.15.100
        ingress:
          configureCertmanager: true
          class: nginx
          annotations:
            cert-manager.io/cluster-issuer: "letsencrypt-cluster-issuer"
          tls:
            secretName: gitlab-tls
        redis:
          host: redis-ha-gitlab-haproxy
          #serviceName: mymaster
          port: 6379
          auth:
            enabled: false
            #secret: gitlab-redis
            #key:
          #sentinels:
          #  - host: redis-ha-gitlab
          #    port: 26379
          #sentinelAuth:
          #  enabled: false
        psql:
          host: gitlab-pgbouncer.postgres-operator.svc
          # serviceName: pgbouncer
          port: 5432
          database: gitlab
          username: gitlab
          applicationName:
          preparedStatements: false
          ###databaseTasks: true #why was this in the example? don't use when main/ci are the same db (I think)
          connectTimeout:
          keepalives:
          keepalivesIdle:
          keepalivesInterval:
          keepalivesCount:
          tcpUserTimeout:
          password:
            useSecret: true
            secret: gitlab-postgres
            key: psql-password
            file:
          #main: {} 
            #database: gitlab_main
            ##username: gitlab
            ##password:
            ##  useSecret: true
            ##  secret: gitlab-postgres
            ##  key: psql-password
            ##  file:
            # host: postgresql-main.hostedsomewhere.else
            # ...
          #ci: {}
            #database: gitlab_main
            ##username: gitlab
            ##password:
            ##  useSecret: true
            ##  secret: gitlab-postgres
            ##  key: psql-password
            ##  file:
            # host: postgresql-ci.hostedsomewhere.else
            # ...          
        smtp:
          enabled: true
          address: 'smtp.zeptomail.com'
          port: 465
          tls: true 
          authentication: 'plain'
          enable_starttls_auto: true
          user_name: 'emailapikey'
          password:
            secret: 'smtp-password'
            key: 'password'
          #domain: 'smtp.zeptomail.com'
        email:
          display_name: 'GitLab'
          from: 'noreply@sentracam.com'
          reply_to: 'noreply@sentracam.com'
        pages:
          enabled: true
      certmanager-issuer:
        email: cory.johnson@sentracam.com # use your real email address here
      nginx-ingress:
        enabled: false
      redis:
        install: false
      postgresql:
        install: false
      gitlab:
        gitlab-pages:
          ingress:
            tls:
              # You need to bring your own wildcard SSL certificate which covers
              # `*.<pages root domain>`. Create a k8s TLS secret with the name
              # `my-custom-pages-tls` with it.
              secretName: gitlab-pages-wildcard
#