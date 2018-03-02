#!/bin/sh
################################################################################
# Script for installing open-data-cam on Ubuntu 16.04
# Author: Florian Porada
#-------------------------------------------------------------------------------
# This script will install 'open data cam' on your Ubuntu 16.04.
#-------------------------------------------------------------------------------
# Make a new file:
# sudo nano install.sh
# Place this content in it and then make the file executable:
# sudo chmod +x install.sh
# Execute the script to install:
# ./install.sh
################################################################################

echo "-----------------------------------------------------------"
echo "----             start basic package setup             ----"
echo "-----------------------------------------------------------"

#--------------------------------------------------
# Update ubuntu packages
#--------------------------------------------------
echo -e "\n---- Update Server ----"
cd ~
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install basic packages
#--------------------------------------------------
echo -e "\n---- Install cURL, git-core, nano, build-essential ----"
sudo apt-get install curl git-core nano build-essential -y

#--------------------------------------------------
# Add sources for ffmpeg v3 and nodejs v8
#--------------------------------------------------
echo -e "\n---- Add sources for ffmpeg v3 and nodejs v8 ----"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo add-apt-repository ppa:jonathonf/ffmpeg-3
sudo apt update && sudo apt upgrade

#--------------------------------------------------
# Install nodejs v8
#--------------------------------------------------
echo -e "\n---- Install nodejs v8 ----"
sudo apt-get install -y nodejs

#--------------------------------------------------
# Install nodejs ffmpeg v3
#--------------------------------------------------
echo -e "\n---- Install ffmpeg v3 ----"
sudo apt-get install -y nodejs

echo "-----------------------------------------------------------"
echo "----           finished basic package setup            ----"
echo "-----------------------------------------------------------"

echo "-----------------------------------------------------------"
echo "----             activate overclocking                 ----"
echo "-----------------------------------------------------------"
#--------------------------------------------------
#  add overclocking script to rc.local
#--------------------------------------------------
echo -e "\n---- Activate overclocking on startup ----"
if [ "`tail -n1 /etc/rc.local`" != "exit 0" ]; then
    sed -i -e '$i \#Maximize performances \n ( sleep 60 && /home/ubuntu/jetson_clocks.sh )&\n' /etc/rc.local
fi

#--------------------------------------------------
#  enable rc-local.service
#--------------------------------------------------
chmod 755 /etc/init.d/rc.local
sudo systemctl enable rc-local.service

echo "-----------------------------------------------------------"
echo "----         start darknet-net installation            ----"
echo "-----------------------------------------------------------"

#--------------------------------------------------
# Install libwsclient
#--------------------------------------------------
echo -e "\n---- Install libwsclient ----"
cd ~
git clone https://github.com/PTS93/libwsclient
cd libwsclient
./autogen.sh
./configure && make && sudo make install

#--------------------------------------------------
# Install liblo
#--------------------------------------------------
echo -e "\n---- Install liblo ----"
cd ~
wget https://github.com/radarsat1/liblo/releases/download/0.29/liblo-0.29.tar.gz
tar xvfz liblo-0.29.tar.gz
cd liblo-0.29
./configure && make && sudo make install

#--------------------------------------------------
# Install json-c
#--------------------------------------------------
echo -e "\n---- Install json-c ----"
cd ~
git clone https://github.com/json-c/json-c.git
cd json-c
sh autogen.sh
./configure && make && make check && sudo make install

#--------------------------------------------------
# Install json-c
#--------------------------------------------------
echo -e "\n---- Install json-c ----"
cd ~
git clone https://github.com/json-c/json-c.git
cd json-c
sh autogen.sh
./configure && make && make check && sudo make install

#--------------------------------------------------
# Install darknet-net
#--------------------------------------------------
echo -e "\n---- Install darknet-net ----"
cd ~
git clone https://github.com/meso-unimpressed/darknet-net.git
cd darknet-net
echo -e "\n---- Download weight files ----"
wget https://pjreddie.com/media/files/yolo-voc.weights
sudo make

echo "-----------------------------------------------------------"
echo "----        finished darknet-net installation          ----"
echo "-----------------------------------------------------------"

echo "-----------------------------------------------------------"
echo "----       start open data cam installation            ----"
echo "-----------------------------------------------------------"

#--------------------------------------------------
# Install open-data-cam
#--------------------------------------------------
echo -e "\n---- Install open-data-cam ----"
cd ~
echo -e "\n---- Install node modules: pm2, next ----"
sudo npm i -g pm2
sudo npm i -g next
git clone https://github.com/moovel/lab-open-data-cam.git
cd lab-open-data-cam
echo -e "\n---- write config.json file ----"
echo '{"PATH_TO_YOLO_DARKNET":"~/darknet-net"}' > config.json
echo -e "\n---- run install and build script ----"
npm install
npm run build
echo -e "\n---- configure open-data-cam to start on boot ----"
sudo pm2 startup  
sudo pm2 start npm --name "open-data-cam" -- start
sudo pm2 save

echo "-----------------------------------------------------------"
echo "----      finished open data cam installation          ----"
echo "-----------------------------------------------------------"