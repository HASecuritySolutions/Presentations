## Try it

This presentation comes with a **Docker** implementation to mimic what was demonstrated. To set up the demo lab, issue the commands below on an Ubuntu 18.04 system.

```bash
cd /opt
sudo apt-get install -y git
sudo git clone https://github.com/HASecuritySolutions/Presentations.git
cd Presentations/How\ to\ create\ alerts\ like\ a\ pro/
sudo bash prereq.sh
echo "alias logstash=\"docker run -it --rm --net=bridge --network=howtocreatealertslikeapro_esnet --name logstash_cmd --hostname logstash_cmd -v /opt/Presentations:/opt/Presentations -v /var/log:/var/log:ro --link elasticsearch -u root -e ELASTICSEARCH_HOST=elasticsearch hasecuritysolutions/logstashoss:v6.2.4 /usr/share/logstash/bin/logstash\"" | sudo tee -a /etc/bash.bashrc
alias logstash="docker run -it --rm --net=bridge --network=howtocreatealertslikeapro_esnet --name logstash_cmd --hostname logstash_cmd -v /opt/Presentations:/opt/Presentations -v /var/log:/var/log:ro --link elasticsearch -u root -e ELASTICSEARCH_HOST=elasticsearch hasecuritysolutions/logstashoss:v6.2.4 /usr/share/logstash/bin/logstash"

# sudo is only required until your next login or reboot
sudo docker-compose up --no-start
sudo docker-compose start
```

### Access Kibana - GUI to see logs and alerts
http://localhost:5601

### Access Cerebro - GUI to see Elasticsearch indices and information
http://localhost:9000

When in Cerebro connect to http://elasticsearch:9200 instead of http://localhost:9200

## Sending test alerts into Logstash for ingestion

### Option 1 - Use Logstash

Logstash can be invoked as an alias was created with the commands at the top of this guide. The only catch is an absolute path must be given. For example, to run the windows_log_cleared.conf (which created a mock event_id 1102 log), issue this command:

```bash
logstash -f /opt/Presentations/How\ to\ create\ alerts\ like\ a\ pro/logstash/windows_log_cleared.conf
```

The logstash folder has multiple configuration files that can be used to trigger specific alerts.

Tab completion is your friend. Please do not complain about the folder path. This is a demo folks. I have a more complete and extensive project in the works. Stay tuned...

### Option 2 - Use netcat to craft a **key-value** log

This docker implementation has a Logstash container running in the background that is listening for **key-value** data on port **6000** or **json** data on port **60000**. Below is an example of sending a mock Windows log clear event (which is event_id 1102).

```bash
echo "event_id=1102 message=TestMessage" | nc 127.0.0.1 6000 -q1
```

### Option 3 - Use netcat to craft a **json** log

This docker implementation has a Logstash container running in the background that is listening for **key-value** data on port **6000** or **json** data on port **60000**. Below is an example of sending a mock Windows log clear event (which is event_id 1102). 

```bash
echo '{ "event_id":1102,"message":"TestMessage" }' | nc 127.0.0.1 60000 -q1
```
