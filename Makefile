up:
	docker-compose up --build --force

mgmt1:
	docker exec rmq1 rabbitmq-plugins enable rabbitmq_management

mgmt2:
	docker exec rmq2 rabbitmq-plugins enable rabbitmq_management

mgmt:
	make mgmt1 && make mgmt2

host:
	docker exec rmq1 cat /etc/hosts

status:
	docker exec rmq1 rabbitmqctl cluster_status

join2:
	docker exec -it rmq2 rabbitmqctl stop_app && \
	docker exec -it rmq2 rabbitmqctl reset && \
	docker exec -it rmq2 rabbitmqctl join_cluster node1@hostname1 && \
	docker exec -it rmq2 rabbitmqctl start_app && \
	docker exec -it rmq2 rabbitmqctl cluster_status

join3:
	docker exec -it rmq3 rabbitmqctl stop_app && \
	docker exec -it rmq3 rabbitmqctl reset && \
	docker exec -it rmq3 rabbitmqctl join_cluster node1@hostname1 && \
	docker exec -it rmq3 rabbitmqctl start_app && \
	docker exec -it rmq3 rabbitmqctl cluster_status

mirror:
	docker exec -it rmq1 rabbitmqctl set_policy ha-all ".*" '{"ha-mode":"all"}'

mirror-nodes:
	docker exec -it rmq1 rabbitmqctl set_policy ha-nodes "^nodes\." '{"ha-mode":"nodes","ha-params":["rabbit@nodeA", "rabbit@nodeB"]}'