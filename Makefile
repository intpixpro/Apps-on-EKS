help:
	@# init_workspace 		- initiate workspace by importing kubeconfig, gpg key and namespace creation.
	@# deploy_apps 			- deploying process of product application grafana, prometheus and postgresql database.
	@# get_ingress_hostname		- get ingress hostname of AWS Load Balancer
	@# all_portforward 		- run port forwarding on grafana, alertmanager and prometheus simultaneously.
	@# prometheus_portforward 	- prometheus port frowarding to any ip address on port 9090.
	@# alertmanager_portforward 	- alertmanager port frowarding to any ip address on port 9093.
	@# grafana_portforward		- grafana port frowarding to any ip address on port 3000.
	@# run_memory_load_on_app 	- run "dd if=/dev/zero of=/dev/null bs=1G" to perform memory loading by comsumpting 1G of memory.
	@./scripts/makefilehelp.sh

all_portforward: grafana_portforward prometheus_portforward alertmanager_portforward

init_workspace:
	/bin/bash ./scripts/init_workspace.sh

deploy_apps:
	cd helmfile/ && helmfile sync --set alertmanagerFiles."alertmanager\.yml".receivers[0].email_configs[0].to=$(EMAIL_NOTIFICATION) --set alertmanagerFiles."alertmanager\.yml".receivers[1].webhook_configs[0].url=$(WEBHOOK_URL)

grafana_portforward:
	/bin/bash ./scripts/run_command.sh grafana_portforward

prometheus_portforward:
	/bin/bash ./scripts/run_command.sh prometheus_portforward

alertmanager_portforward:
	/bin/bash ./scripts/run_command.sh alertmanager_portforward

run_memory_load_on_app:
	/bin/bash ./scripts/run_command.sh run_memory_load_on_app

get_ingress_hostname:
	/bin/bash ./scripts/run_command.sh get_ingress_hostname
