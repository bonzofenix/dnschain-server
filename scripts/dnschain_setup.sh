#!/usr/bin/env bash


NAMECOIN_DIR=/home/ubuntu/.namecoin
NAMECOIN_CONF=$NAMECOIN_DIR/namecoin.conf 
DNSCHAIN_DIR=/home/ubuntu/.dnschain

# Install Namecoin 

if [ ! -f /etc/apt/sources.list.d/namecoin.list ]; then
  sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/p_conrad:/coins/xUbuntu_14.04/ /' > /etc/apt/sources.list.d/namecoin.list"
fi

if [ ! -f Release.key ]; then
  wget http://download.opensuse.org/repositories/home:p_conrad:coins/xUbuntu_14.04/Release.key
  sudo apt-key add - < Release.key
fi

sudo apt-get update
sudo apt-get install -y namecoin


# Create namecoin configs

if [ ! -f $NAMECOIN_CONF ]; then
  sudo mkdir -p $NAMECOIN_DIR \
    && echo "rpcuser=`whoami`" >> $NAMECOIN_CONF \
    && echo "rpcpassword=`openssl rand -hex 30/`" >> $NAMECOIN_CONF \
    && echo "rpcport=8336" >> $NAMECOIN_CONF \
    && echo "daemon=1" >> $NAMECOIN_CONF 
fi

# initclt for namecoin

sudo mv /vagrant/templates/namecoind-init.conf /etc/init/namecoin.conf

# install and configure powerdns
sudo apt-get install -y pdns-recursor
sudo rec_control ping  
sudo mv /vagrant/templates/recursor.conf /etc/powerdns/recursor.conf
sudo service pdns-recursor restart

# install and configure dnschain
sudo apt-get update -y
sudo apt-get install -y git npm nodejs-legacy
sudo npm install -g coffee-script
sudo npm install -g dnschain

sudo mkdir -p $DNSCHAIN_DIR
sudo mv /vagrant/templates/dnschain.conf $DNSCHAIN_DIR/dnschain.conf

# initclt for dnschain
sudo mv /vagrant/templates/dnschain-init.conf /etc/init/dnschain.conf

sudo initctl reload-configuration
sudo shutdown -r now
