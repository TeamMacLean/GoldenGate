# Golden Gate Assembly Tool

[![Build Status](https://travis-ci.org/wookoouk/GoldenGate.svg)](https://travis-ci.org/wookoouk/GoldenGate)

<img src="https://raw.githubusercontent.com/wookoouk/GoldenGate/master/public/gate2.png">

>A tool for SynBio

Golden Gate is a tool developed by Martin Page of [Team Maclean](http://danmaclean.info) for SynBio of [The Sainsbury Laboratory](http://tsl.ac.uk).
The tool was designed to work with the data found [here](https://github.com/TSLSynBio/Golden-Gate-Data/)  but can work with any data that follows the same annotation style.

## Install
Depends on:
* Perl
  * "5.20"
  * "5.18"
  * "5.16"
  * "5.14"
  * "5.12"
  * "5.10"
* NodeJS
* MongoDB
* CpanM

Install Bower
```sh
$ npm install -g bower
```

Install Perl modules
```sh
$ cpanm --installdeps .
```

Install web components
```sh
$ bower install
```

Checkout data
```sh
$ cd data
$ git clone https://github.com/TSLSynBio/Golden-Gate-Data.git
```

Start the app
```sh
$ perl goldengate.pl daemon -m production
```

## Docker
To test the app via docker
```sh
$ docker pull wookoouk/goldengate
$ sudo docker run --name goldengate -d wookoouk/goldengate
```

[More info about this Docker container](https://registry.hub.docker.com/u/wookoouk/goldengate/)

