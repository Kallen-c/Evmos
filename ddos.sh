#Update 'database', update distribution
sudo apt update && sudo apt upgrade -y

#Installing additional software packages:
sudo apt install -y vim nano git curl wget htop bash-completion xz-utils zip unzip ufw locales net-tools mc jq make gcc gpg build-essential ncdu sysstat tmux

#Install docker
sudo apt install ca-certificates curl gnupg lsb-release

#Add the Docker GPG key to the system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 

#Add the Docker repository to the system
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the list of packages in the repositories
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

#Check docker version
sudo docker --version

#Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

#Set to run Docker Compose
sudo chmod +x /usr/local/bin/docker-compose

#Check docker version
docker-compose --version

#Run container
docker run -ti --rm alpine/bombardier -c 1000 -d 3600s -l https://evmos.org/

