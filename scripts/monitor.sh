#!/bin/bash

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch |sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt updateA -y
sudo apt install elasticsearch -y
sudo sed '/^network.host/d' /etc/elasticsearch/elasticsearch.yml
cat << EOF | sudo tee -a /etc/elasticsearch/elasticsearch.yml
network.host: localhost
EOF
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
curl -X GET "localhost:9200"

sudo apt install kibana -y
sudo systemctl enable kibana
sudo systemctl start kibana
echo "kibanaadmin:`openssl passwd -apr1`" | sudo tee -a /etc/nginx/htpasswd.users
cat << EOF | sudo tee -a /etc/nginx/sites-available/your_domain
server {
    listen 80;

    server_name your_domain;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
sudo ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/your_domain
sudo nginx -t
sudo systemctl reload nginx
sudo ufw allow 'Nginx Full'

sudo apt install logstash -y
cat << EOF | sudo tee -a /etc/logstash/conf.d/02-beats-input.conf
input {
  beats {
    port => 5044
  }
}
EOF
cat << EOF | sudo tee -a /etc/logstash/conf.d/30-elasticsearch-output.conf
output {
  if [@metadata][pipeline] {
	elasticsearch {
  	hosts => ["localhost:9200"]
  	manage_template => false
  	index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  	pipeline => "%{[@metadata][pipeline]}"
	}
  } else {
	elasticsearch {
  	hosts => ["localhost:9200"]
  	manage_template => false
  	index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
	}
  }
}
EOF
sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t
sudo systemctl start logstash
sudo systemctl enable logstash

sudo apt install filebeat -y
cat << EOF | sudo tee -a /etc/filebeat/filebeat.yml
Content
EOF
