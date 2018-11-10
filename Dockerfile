FROM alpine

LABEL maintainer "Pavel Serikov <pavelsr@cpan.org>"

RUN apk update && \
    apk add perl perl-dev g++ make wget curl && \
    curl -L https://cpanmin.us | perl - App::cpanminus && \
    rm -rf /root/.cpanm/* /usr/local/share/man/*

RUN apk add mariadb mariadb-dev openssl

COPY cpanfile ./
RUN  cpanm -v --installdeps . && rm cpanfile

RUN apk add tzdata
RUN echo '* * * * * perl /root/www/insert.pl 2>&1' > /etc/crontabs/root

WORKDIR /root/www
