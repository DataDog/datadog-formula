sudo add-apt-repository ppa:saltstack/salt -y
sudo apt-get update -y
sudo apt-get install salt-master -y
sudo apt-get install salt-minion -y
# Accept all keys
sudo salt-key -y -A
