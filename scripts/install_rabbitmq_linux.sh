cd /opt

cat > /etc/yum.repos.d/rabbitmq_rabbitmq-server.repo<<REALEND
[rabbitmq_rabbitmq-server]
name=rabbitmq_rabbitmq-server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/7/x86_64
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_rabbitmq-server-source]
name=rabbitmq_rabbitmq-server-source
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/7/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
REALEND

cat > /etc/yum.repos.d/rabbitmq_erlang.repo<<REALEND
[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://packagecloud.io/rabbitmq/erlang/el/7/x86_64
repo_gpgcheck=1
gpgcheck=0
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
       https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_erlang-source]
name=rabbitmq_erlang-source
baseurl=https://packagecloud.io/rabbitmq/erlang/el/7/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
       https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
REALEND

rm -fr /var/cache/yum/*
yum clean all
yum repolist -y

# yum remove rabbitmq-server -y
yum install rabbitmq-server -y

#####################
# OR Install rabbitmq
cd /opt
sudo wget https://github.com/rabbitmq/erlang-rpm/releases/download/v24.1.7/erlang-24.1.7-1.el8.x86_64.rpm
sudo wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.9.11/rabbitmq-server-3.9.11-1.el8.noarch.rpm
rpm -Uvh erlang-24.1.7-1.el8.x86_64.rpm
rpm -Uvh rabbitmq-server-3.9.11-1.el8.noarch.rpm
#####################

systemctl enable --now rabbitmq-server
systemctl start  rabbitmq-server
systemctl status  rabbitmq-server

rabbitmq-plugins enable rabbitmq_management
firewall-cmd --permanent --add-port={5672,15672}/tcp
firewall-cmd --reload
rabbitmqctl list_users

rabbitmqctl add_user user1 user1@123
rabbitmqctl set_user_tags user1 administrator
rabbitmqctl set_permissions -p / user1 ".*" ".*" ".*"