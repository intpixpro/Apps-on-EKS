# Step by step instructions of infrastructure creation

In this instruction you will find infomation how to create Kubernetes cluster with terraform on AWS - Elastic Kubernetes Service (EKS) and how to deploy simple application using helmfile to EKS.

Following tools are required to create the infrastructure:

- terraform
- kubectl
- helm & helm secrets plugin
- helmfile
- aws cli
- aws-iam-authenticator
- makefile

>As any engineer use any operating system I decided to unify the process of tools installation. So I prepared a Dockerfile where are mentioned all required tools. You just need to build a docker comtainer and you will be able to manage the infrastructure in this project.

## 1. Building and running the docker container

First what we shall do is to build container with the following command:

```shell
$ docker build . -t controller:0.1
```
Next you can run container with the following command:

```shell
$ docker run  -d --privileged \
            -v ~/.aws/:/root/.aws \
            -v ${PWD}:/project \
            -p 9090:9090 \
            -p 9093:9093 \
            -p 3000:3000 \
            -e EMAIL_NOTIFICATION='email_to_send_alerts@gmail.com' \
            -e WEBHOOK_URL='http://webhook_alerts.com/test' \
            -it controller:0.1 bash
```
- ```-v ~/.aws/:/root/.aws \``` - here we attach a AWS config and credential to container.

- ```-v ${PWD}:/project \``` - the flag means that it mounts current directory to the container's directory with the name `project`, so please consider to run the container from the root of the project.

- following ports are related to the services as described below:
    - ```-p 9090:9090 \``` - Prometheus
    - ```-p 9093:9093 \``` - Alertmanager
    - ```-p 3000:3000 \``` - Prometheus

- ```-e EMAIL_NOTIFICATION='email_to_send_alerts@gmail.com' \``` - this environment variable is required for ***alert notification to email***, so please set your own email.

- ```-e WEBHOOK_URL='http://webhook_alerts.com/test' \``` - - this environment variable is required to send ***HTTP POST alert notification***.

Below the command to get a bash shell in the container:

```shell
$ docker exec -it container_id bash
```

## 2. EKS installation

Now we are going to proceed with EKS installation.
From directory `/project/terraform-eks-deploy`, you need to initialise terraform and then install EKS as follows:

```shell
$ terraform init
```
```shell
$ terraform plan
```
```shell
$ terraform apply
```
It takes about 15-20 minutes for completed installation.

### 3. Commands descriptions

From the root directory `/project` call command
```shell
$ make
```
And you will find command decsriptions as follows:

```
 init_workspace                  - initiate workspace by importing kubeconfig, gpg key and namespace creation.
 deploy_apps                    - deploying process of product application grafana, prometheus and postgresql database.
 all_portforward                - run port forwarding on grafana, alertmanager and prometheus simultaneously.
 prometheus_portforward         - prometheus port frowarding to any ip address on port 9090.
 alertmanager_portforward       - alertmanager port frowarding to any ip address on port 9093.
 grafana_portforward            - grafana port frowarding to any ip address on port 3000.
 run_memory_load_on_app         - run "dd if=/dev/zero of=/dev/null bs=1G" to perform memory loading by comsumpting 1G of memory.
```

## 4. Workspace prepration

Using below command we initialise our workspace for the following reasons:

- get kubeconfig to manage the Kubernetes cluster
- import gpg key to decrypt secrets
- create two namespaces - project and monitoring

```shell
$ make init_workspace
```

>During script execution you will be asked to provide passphrase to perform importing of gpg key.

```
secret
```

## 5. Application deployment

The project kanban-board includes 3 services:
- database,
- backend service (kanban-app, written in Java with Spring Boot)
- and frontend (kanban-ui, written with Angular framework).

!!!!!!To enter one of these two UI apps user will need to type one of following URLs in the web browser:
kanban.k8s.com
adminer.k8s.com!!!!!

Before deploying process we need to reload gpg agent to be able to decrypt the secrets.

```shell
$ GPG_TTY=$(tty)
$ export GPG_TTY
```
Now we are ready to deploy applications to the cluster.

```shell
$ make deploy_apps
```

During deploying process you will be asked again to provide passphrase.

```
secret
```

## 6. Portforwarding

We are going to use Grafana, Prometheus and Alertmanager to monitor applications. There are separate comands to make portforwaring for each of them but you can do it with only one of it.

```shell
$ make all_portforward
```

>During script implementation you will find in output Grafana credentials for UI.

Below are ports related to monitoring tool:

```
127.0.0.1:3000 - Grafana
127.0.0.1:9090 - Prometheus
127.0.0.1:9093 - Alertmanager
```

## 7. Loading tests

Now we can initiate the load to the applications.

```shell
$ make run_memory_load_on_app
```

In few minutes you should get alet notification to you email.

## 8. Destroying EKS cluster

After that we can destroy EKS cluster

```shell
$ terraform destroy
```

## Conclusion

In this article I've tried to cover all requirements from the tasks.
- The process of EKS installation.

- The deployment processes of applications and monitoring tools, uncluding the following:
    - alert rules,
    - grafana dashboards,
    - with email and webhook values substitution.

- secrets for postgres and prometheus were ecnrypted with helm secrets plugin.

- All processes were automated as much as possible with terraform, helmfile, makefile and bash scripting.


