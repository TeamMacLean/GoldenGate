FROM ubuntu

MAINTAINER Martin Page <wookoouk@gmail.com>

# Get NodeJS + Bower
RUN apt-get update
RUN apt-get install -y python-software-properties python
RUN add-apt-repository ppa:chris-lea/node.js
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y nodejs

RUN npm install -f bower

# Get Build Essentials
RUN apt-get update && apt-get install -y build-essential

# Install Perl requirements
RUN curl -L cpanmin.us | perl - Mojolicious
RUN curl -L cpanmin.us | perl - -n Mango
RUN curl -L cpanmin.us | perl - -n Data::Printer
RUN curl -L cpanmin.us | perl - -n JSON
RUN curl -L cpanmin.us | perl - -n Bio::SeqIO

# Install MongoDB
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
RUN echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
RUN apt-get -y update
RUN apt-get -y install mongodb-10gen

# Expose server port
EXPOSE 6379
