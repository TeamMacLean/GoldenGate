# Golden Gate Assembly Tool

<img align="right" src="https://raw.githubusercontent.com/wookoouk/GoldenGate/master/public/gate2.png">

> A tool for SynBio

## Install
Depends on:
* NodeJS
* Perl
* MongoDB

Install Bower
```sh
$ npm install -f bower
```

Install Perl modules
```sh
$ curl -L cpanmin.us | perl - Mojolicious
$ curl -L cpanmin.us | perl - -n Mango
$ curl -L cpanmin.us | perl - -n Data::Printer
$ curl -L cpanmin.us | perl - -n JSON
$ curl -L cpanmin.us | perl - -n Bio::SeqIO
```

https://registry.hub.docker.com/u/wookoouk/goldengate/