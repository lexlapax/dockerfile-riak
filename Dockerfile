# riak
# this file is at https://github.com/lexlapax/dockerfile-riak/blob/master/Dockerfile
# based on https://github.com/hectcastro/docker-riak
# with changes to not use pipeworks for creating a cluster
# see https://github.com/lexlapax/dockerfile-riak/blob/master/README.md

FROM ubuntu:precise
MAINTAINER Lex Lapax <lexlapax@gmail.com>

# Update the APT cache
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y


# Install and setup project dependencies
RUN apt-get install -y curl lsb-release supervisor openssh-server

RUN mkdir -p /var/run/sshd

RUN locale-gen en_US en_US.UTF-8

# Hack for initctl
# See: https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl


ADD https://raw.github.com/lexlapax/dockerfile-riak/master/etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo 'root:basho' | chpasswd

# Add Basho's APT repository
RUN curl http://apt.basho.com/gpg/basho.apt.key | apt-key add -
RUN echo "deb http://apt.basho.com $(lsb_release -sc) main" >> /etc/apt/sources.list.d/basho.list

RUN apt-get update

# Install Riak and prepare it to run
RUN apt-get install -y riak

RUN sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/app.config

# switch to leveldb as the riak backend
RUN sed -i -e s/riak_kv_bitcask_backend/riak_kv_eleveldb_backend/g /etc/riak/app.config
# enable search. the sed command below only replaces the first line it matches
RUN sed -i -e 0,/"enabled, false"/{s/"enabled, false"/"enabled, true"/} /etc/riak/app.config

# enable admin panel. replaces the second line it matches
RUN sed -i -e 1,/"enabled, false"/{s/"enabled, false"/"enabled, true"/} /etc/riak/app.config

#change the admin user
RUN sed -i.bak 's/"user", "pass"/"admin", "adminpass"/' /etc/riak/app.config

RUN echo "sed -i.bak \"s/-name riak@.\+/-name riak@\$(ip addr show eth0 scope global primary|grep inet|awk '{print \$2}'|awk -F'/' '{print \$1}')/\" /etc/riak/vm.args" > /etc/default/riak
RUN echo "ulimit -n 4096" >> /etc/default/riak

# Expose Protocol Buffers and HTTP interfaces
EXPOSE 8087 8098 22

CMD ["/usr/bin/supervisord"]
