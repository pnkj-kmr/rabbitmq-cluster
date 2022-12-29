# RabbitMQ - Clustering - Mirroring - High Availability

_rabbitmq [3.9] | choose higher version if you like_

## rabbitmq on cluster - these setups help

1. RabbitMQ Installation [skip if already installed]
2. Hostname Resolution Setup [or we can skip this by IP address]
3. RabbitMQ Clustering
4. RabbitMQ Mirroring

### 1. RabbitMQ Installation

---

_Here we are refering the linux machine to install rabbitmq. To install [refer here](https://www.rabbitmq.com/install-rpm.html) or below command on terminal to install_

```
cat > /etc/yum.repos.d/rabbitmq.repo<<REALEND
# In /etc/yum.repos.d/rabbitmq.repo

##
## Zero dependency Erlang
##

[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://packagecloud.io/rabbitmq/erlang/el/8/$basearch
repo_gpgcheck=1
gpgcheck=1
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_erlang-source]
name=rabbitmq_erlang-source
baseurl=https://packagecloud.io/rabbitmq/erlang/el/8/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

##
## RabbitMQ server
##

[rabbitmq_server]
name=rabbitmq_server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/8/$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_server-source]
name=rabbitmq_server-source
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/8/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
REALEND

# use if some cache exists
rm -rf /var/cache/yum/*
yum clean all
yum repolist -y

yum -q makecache -y --disablerepo='*' --enablerepo='rabbitmq_erlang' --enablerepo='rabbitmq_server'
yum install socat logrotate -y
yum install --repo rabbitmq_erlang --repo rabbitmq_server erlang rabbitmq-server -y
```

_if linux machine has firewall service running, we need to enable rabbitmq ports by running below command_

```
firewall-cmd --permanent --add-port={5672,15672,4369,25672,35672}/tcp
firewall-cmd --reload
```

_now, let's run rabbitmq as a service on linux, and verify the service status_

```
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
systemctl status rabbitmq-server
```

_**REPEAT** the step in Each & Every machine_

### 2. Hostname Resolution Setup

---

_We are setting up rabbitmq with 3 linux machine, here we are the ips and their hostname reference as, modify as per your structure_

_Now, let's add hosts as known host for the machine, login to hostname1 machine and run the below command_

```
cat >> /etc/hosts <<EOF
192.168.1.101 hostname1
192.168.1.102 hostname2
192.168.1.103 hostname3
EOF

cat /etc/hosts
```

_**REPEAT** the step 3 in Each & Every machine_

### 3. RabbitMQ Clustering

---

_Here, we are setting up rabbitmq with [clustering](https://www.rabbitmq.com/clustering.html), to start the clustering mode, we need to setup erlang.cookie file_

_[linux]: /var/lib/rabbitmq/.erlang.cookie_

```
ADD_YOUR_SECRET_HERE
```

_modify the below parameters in rabbitmq.conf file, and restart the rabbitmq service_

<!-- RABBITMQ_CONFIG_FILE= -->

_setup the os environment variable as **RABBITMQ_CONFIG_FILE=etc/rabbitmq/rabbitmq.conf** at linux machine_

_[linux]: /etc/rabbitmq/rabbitmq.conf_

```
loopback_users.guest = false
listeners.tcp.default = 5672

cluster_formation.peer_discovery_backend = classic_config
cluster_formation.classic_config.nodes.1 = rabbit@hostname1
cluster_formation.classic_config.nodes.2 = rabbit@hostname2
cluster_formation.classic_config.nodes.3 = rabbit@hostname3
```

_now, restart the service by running_

```
systemctl restart rabbitmq-server
```

_**REPEAT** the step in Each & Every machine_

### 4. RabbitMQ Mirroring

---

_Finally, this [mirroring](https://www.rabbitmq.com/ha.html) step **ONLY** performed in primary node you choose_

_We are refering hostname1 as primary node, login to hostname1 machine and run below command to connect with rabbitmqctl as_

```
rabbitmqctl set_policy ha-all ".*" '{"ha-mode":"all"}'
```

_completed :)_

### ADDITIONAL

---

#### A. How to run rabbitmq cluster with docker compose

_**prerequisites**_

- Docker should be running
- Docker-compose should be installed

_navigate to the path of **docker-compose.yml**, and the command as_

```
docker-compose up --build --force
```
