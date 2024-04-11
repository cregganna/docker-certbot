# syntax=docker/dockerfile:1

# Runs:
# Uses EFF's certbot to create and manage LetsEncrypt's certificates with an
# acme-dns-auth hook. Can be run interactively or via command parameters. It is
# not intended to be run as a background container.

## Usee Debian as Alpine does not have motion
FROM debian:bookworm-slim
LABEL org.opencontainers.image.authors="tony.jewell@cregganna.com"

# Contains CertBot working files, LetsEncrypt account details and generated certificates
VOLUME ["/certificates"]

RUN mkdir /certificates
RUN ln -s /certificates /etc/letsencrypt

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install tini certbot
RUN apt-get clean

COPY run.sh /run.sh
ADD https://github.com/joohoi/acme-dns-certbot-joohoi/raw/master/acme-dns-auth.py /acme-dns-auth.py
RUN sed -i -e '1s/python$/python3/' /acme-dns-auth.py
RUN chmod 755 /run.sh /acme-dns-auth.py

# There's an annoying print in certbot about where its putting the debug:
#	"Saving debug log to /var/log/letsencrypt/letsencrypt.log"
# We disable this here:
RUN sed -i -e "s/print(f'Saving debug log/pass # &/" /usr/lib/python3/dist-packages/certbot/_internal/log.py 

# Use tini otherwise defunct processes are not reaped when inherited by PID=1
ENTRYPOINT [ "/usr/bin/tini", "--", "/run.sh" ]
