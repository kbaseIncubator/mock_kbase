FROM kbase/runtime:latest

WORKDIR /opt/run/

# set the GOPATH
ENV GOPATH=/opt/go PATH=$PATH:$GOPATH/bin
RUN mkdir /opt/go

# install dependencies for SHOCK
RUN \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list && \
    apt-get update && \
    apt-get install -y \
        libsasl2-dev libsasl2-modules-gssapi-mit \
        mongodb-10gen=2.4.14 \
        supervisor \
        expect

# update golang to 1.3.x
RUN \
    apt-get purge -y golang* && \
    cd /usr/local && \
    curl -O https://storage.googleapis.com/golang/go1.3.linux-amd64.tar.gz && \
    tar xzf go1.3.linux-amd64.tar.gz && \
    cd /usr/local/bin && ln -s /usr/local/go/bin/* .

# install SHOCK
RUN \
    mkdir -p /usr/local/shock/site /usr/local/shock/data /usr/local/shock/logs && \
    git clone https://github.com/MG-RAST/Shock && \
    cd Shock && \
    git checkout 194593b && \
    cd .. && \
    mkdir -p $GOPATH/src/github.com/MG-RAST && \
    cp -r Shock $GOPATH/src/github.com/MG-RAST/ && \
    cp Shock/Makefile $GOPATH/ && \
    cd $GOPATH && \
    make install && \
    cd -

ADD ./scripts /opt/run/scripts
ADD ./config /opt/run/config
COPY ./data/shock_mongodb.tar.gz /tmp

# unpack initial SHOCK MongoDB
RUN \
    cd /tmp && \
    tar xzf shock_mongodb.tar.gz && \
    cp -R data/mongodb/* /var/lib/mongodb/ && \
    rm -rf data shock_mongodb.tar.gz

# setup supervisord
COPY ./config/supervisord.conf /etc/supervisor/conf.d/kbase.conf

EXPOSE 7078

#VOLUME ["/var/lib/mongodb"]
VOLUME ["/usr/local/shock/data"]

CMD ["/usr/bin/supervisord", "-n"]