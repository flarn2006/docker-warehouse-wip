FROM python:2

RUN apt-get update

WORKDIR /root/openssl
RUN git init
RUN git remote add origin https://github.com/openssl/openssl.git
RUN git fetch origin OpenSSL_1_1_1-stable
RUN git checkout FETCH_HEAD

WORKDIR ..
RUN git clone --depth=1 https://github.com/nginx/nginx.git
RUN git clone https://github.com/barronwaffles/dwc_network_server_emulator.git dwc

WORKDIR nginx
RUN auto/configure --with-http_ssl_module --with-openssl=/root/openssl --with-openssl-opt="enable-weak-ssl-ciphers enable-ssl3 enable-ssl3-method enable-deprecated"
RUN make install
RUN make clean

RUN apt-get install -y python-zope.interface
RUN pip install twisted

WORKDIR /root/ssl
COPY WII_NWC_1_CERT.p12 .
RUN openssl pkcs12 -in WII_NWC_1_CERT.p12 -clcerts -nokeys -passin pass:alpine | sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > CA.crt
RUN openssl pkcs12 -in WII_NWC_1_CERT.p12 -nocerts -passin pass:alpine -nodes -out CA.key

EXPOSE 80 443 9001 9002 9003 9998 27500 27900 27901 28910 29900 29901 29920

WORKDIR /root
COPY start.sh .

COPY nginx.conf /usr/local/nginx/conf/

CMD /bin/bash /root/start.sh
