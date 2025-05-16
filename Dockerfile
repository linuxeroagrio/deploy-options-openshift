FROM quay.io/linuxeroagrio/webserver:1.26.3-v3

LABEL org.opencontainers.image.authors="jvarela@redhat.com" \
      io.openshift.tags="webserver,nginx,my-org valid,1.26.3"

ADD app-source/html/ /opt/nginx/html
