FROM alpine:3.19.1 AS difff-src

ARG targetRevision=c99e671c39f27d4d3d3e18f3119d9a7a51532cad

RUN apk add unzip wget sed
RUN wget https://github.com/meso-cacase/difff/archive/${targetRevision}.zip -O difff.zip \
  && unzip difff.zip -d /opt/ \
  && mv /opt/difff-${targetRevision} /opt/difff

# Fix the base URI to be the environment variable
RUN sed -i -e "19{s|my \$url = 'https://difff.jp/' ;|my \$url = \$ENV{BASE_URI};|; t; q1;}" /opt/difff/difff.pl \
 && sed -i -e "16{s|my \$url = './' ;|my \$url = \$ENV{BASE_URI};|; t; q2;}" /opt/difff/save.cgi \
 && sed -i -e "14{s|my \$url = './' ;|my \$url = \$ENV{BASE_URI};|; t; q3;}" /opt/difff/delete.cgi  \
 && sed -i -e "19{s|my \$url = 'https://difff.jp/en/' ;|my \$url = \$ENV{BASE_URI}.'en/';|; t; q4;}" /opt/difff/en/difff_en.pl \
 && sed -i -e "16{s|my \$url = './' ;|my \$url = \$ENV{BASE_URI}.'en/';|; t; q5;}" \
           -e "470{s|return \$filename ;|return '../'.\$filename ;|; t; q6;}" /opt/difff/en/save.cgi  \
 && sed -i -e "14{s|my \$url = './' ;|my \$url = \$ENV{BASE_URI}.'en/';|; t; q7;}" /opt/difff/en/delete.cgi

FROM alpine:3.19.1

RUN addgroup -g 1000 -S nonroot \
    && adduser -u 1000 -S nonroot -G nonroot \
    && apk add --no-cache \
    lighttpd \
	perl \
    perl-digest-md5 \
    diffutils

COPY --chown=nonroot:nonroot lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY --from=difff-src --chown=nonroot:nonroot /opt/difff/ /opt/difff/

USER nonroot

EXPOSE 8080
ENV BASE_URI="http://localhost:8080/"

ENTRYPOINT /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf 3>&1
