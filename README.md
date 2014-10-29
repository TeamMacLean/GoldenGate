# Golden Gate Assembly Tool

<img src="https://raw.githubusercontent.com/wookoouk/GoldenGate/master/public/gate2.png">

Golden Gate is a tool developed by Martin Page of [Team Maclean](http://danmaclean.info) for SynBio of [The Sainsbury Laboratory](http://tsl.ac.uk).
The tool was designed to work with the data found [here](https://github.com/TSLSynBio/Golden-Gate-Data/)  but can work with any data that follows the same annotation style.

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
$ bin/start
```

https://registry.hub.docker.com/u/wookoouk/goldengate/