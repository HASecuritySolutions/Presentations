## Try it

This presentation comes with a **Docker** implementation to mimic what was demonstrated. To set up the demo lab, issue the commands below on an Ubuntu 18.04 system.

```bash
cd /opt
sudo apt-get install -y git
sudo git clone https://github.com/HASecuritySolutions/Presentations.git
cd Presentations/How\ to\ create\ alerts\ like\ a\ pro/
sudo bash prereq.sh

# sudo is only required until your next login or reboot
sudo docker-compose up --no-start
sudo docker-compose start
```
