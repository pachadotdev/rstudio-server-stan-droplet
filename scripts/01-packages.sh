#!/bin/bash

# Add a swap file to prevent build time OOM errors
fallocate -l 8G /swapfile
mkswap /swapfile
swapon /swapfile

# add CRAN to apt sources
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
printf '\n#CRAN mirror\ndeb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/\n' | sudo tee -a /etc/apt/sources.list

# update apt
apt-get -y update
apt-get -y upgrade

# requisites for RStudio
apt-get -y install gdebi-core

# requisites for R packages
apt-get -y install libxml2-dev libssl-dev libcurl4-openssl-dev default-jdk

# install optimized BLAS
apt-get -y install libopenblas-dev

# install R
apt-get -y install r-base r-base-dev

# install Digital Ocean agent
curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash

# install R packages
R --vanilla << EOF
if (!require("rmarkdown")) {
  install.packages(c("rstan", "brms", "rstanarm", "tidyverse"), repos = "http://cran.us.r-project.org")
}
q()
EOF

# install RStudio Server
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5033-amd64.deb
gdebi --n rstudio-server-1.2.5033-amd64.deb
rm rstudio-server-1.2.5033-amd64.deb

# open ports
ufw allow http
ufw allow https
ufw allow ssh
ufw allow 8787

# Disable and remove the swapfile prior to snapshotting
swapoff /swapfile
rm -f /swapfile
