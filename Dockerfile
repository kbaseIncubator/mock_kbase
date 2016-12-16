FROM kbase/runtime:latest

WORKDIR /opt/run/

# set the GOPATH
ENV GOPATH=/opt/go PATH=$PATH:$GOPATH/bin
RUN mkdir /opt/go

# Install supervisord, nginx, mongodb, mysql
RUN \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        supervisor \
        nginx \
        mongodb-10gen=2.4.14 \
        uwsgi-plugin-psgi \
        debconf-utils && \
    echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mysql-server-5.6 mysql-client-5.6 mysql-client-core-5.6 && \
    usermod -d /var/lib/mysql/ mysql && \
    cp /usr/share/doc/mysql-server-5.6/examples/my-default.cnf /usr/share/mysql/ && \
    mysql_install_db --user=mysql --defaults-file=/var/lib/mysql

# install dependencies for SHOCK
RUN \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libsasl2-dev libsasl2-modules-gssapi-mit && \
    apt-get purge -y golang* && \
    cd /usr/local && \
    curl -O https://storage.googleapis.com/golang/go1.3.linux-amd64.tar.gz && \
    tar xzf go1.3.linux-amd64.tar.gz && \
    cd /usr/local/bin && ln -s /usr/local/go/bin/* .

ADD ./build /opt/run/build

# install SHOCK
RUN \
    mkdir -p /usr/local/shock/site /usr/local/shock/data /usr/local/shock/logs && \
    git clone https://github.com/MG-RAST/Shock && \
    cd Shock && \
    git checkout 194593b && \
    cd .. && \
    mkdir -p $GOPATH/src/github.com/MG-RAST && \
    cp -R Shock $GOPATH/src/github.com/MG-RAST/ && \
    cp Shock/Makefile $GOPATH/ && \
    cd $GOPATH && \
    make install && \
    cd -

# unpack initial SHOCK MongoDB
COPY ./build/data/shock_mongodb.tar.gz /tmp
RUN \
    cd /tmp && \
    tar xzf shock_mongodb.tar.gz && \
    cp -R data/mongodb/* /var/lib/mongodb/ && \
    rm -rf data shock_mongodb.tar.gz

# must install some kbase code to build handle_service and handle_mngr
RUN \
    cd /kb && \
    git clone https://github.com/kbase/dev_container && \
    cd dev_container/modules && \
    git clone https://github.com/kbase/kbapi_common && \
    git clone https://github.com/kbase/typecomp && \
    git clone https://github.com/kbase/auth && \
    git clone https://github.com/kbase/jars && \
    cd /kb/dev_container && \
    ./bootstrap /kb/runtime && \
    . ./user-env.sh && make && make deploy && \
    cd /opt/run

# install Handle service, Handle manager service, Workspace service
RUN \
    mkdir -p /var/log/kbase && \
    pip install sphinx --upgrade && \
    cd /kb/dev_container/modules && \
    git clone https://github.com/kbase/handle_service && \
    git clone https://github.com/kbase/handle_mngr && \
    git clone https://github.com/kbase/workspace_deluxe -b 0.5.0 && \
    cd .. && \
    . ./user-env.sh && make && make deploy && \
    cd /opt/run

# NGINX HTTP, NGINX HTTPS, Auth, SHOCK, Handle, Workspace ports
EXPOSE 80 443 7039 7044 7109 7058

# Data volumes for SHOCK files, Handle/HandleMngr MySQL DBs, SHOCK/Workspace Mongo DBs
VOLUME ["/usr/local/shock/data", "/var/lib/mysql", "/var/lib/mongodb"]

# setup kbase config
COPY ./build/config/kbase.cfg /kb/deployment/deployment.cfg

# setup mysqld
COPY ./build/config/my.cnf /etc/mysql/my.cnf

# setup supervisord
COPY ./build/config/supervisord.conf /etc/supervisor/conf.d/kbase.conf

CMD ["/usr/bin/supervisord", "-n"]