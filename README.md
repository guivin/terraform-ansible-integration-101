# terraform-ansible-integration-101
Example to automate infrastructure with Terraform and Ansible

This repository showcases how to seamlessly integrate Terraform and Ansible to automate infrastructure deployment on DigitalOcean. Terraform handles infrastructure provisioning, while Ansible manages configuration with precision.

By leveraging the Ansible provider for Terraform, this example unifies both tools to provision and configure resources in a single, streamlined workflow, enhancing automation and efficiency.

## Overview 

* Terraform: Manages the provisioning of infrastructure as code (IaC).
* Ansible: Handles configuration management and automates repetitive tasks.
* Integration: Uses the Ansible provider for Terraform to bridge provisioning and configuration seamlessly.

## Pre-requisites

Ensure the following tools are installed before running the example:

* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [DigitalOcean Token](https://docs.digitalocean.com/reference/api/create-personal-access-token/)

## How to test the example

1. Install ansible galaxy requirements :

```
$ ansible-galaxy install -r requirements.yml
```

2. Deploy Infrastructure-as-Code (IaC) with Terraform :

```
$ read -s DO_TOKEN
$ terraform apply -var "do_token=$DO_TOKEN"
```

3. Execute the Ansible playbook on the target :

```
$ ansible-playbook playbook.yml -i inventory.yml

PLAY [Webservers] ****************************************************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************************************************************************************
ok: [162.243.37.67]

TASK [Ensure NGINX package is present.] ******************************************************************************************************************************************************************************************************************************************************************
changed: [162.243.37.67]

TASK [Ensure NGINX is started and enabled.] **************************************************************************************************************************************************************************************************************************************************************
ok: [162.243.37.67]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************************************************************************************
162.243.37.67              : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

4. Login to the target host

```
$ ssh-agent -t 3600
$ ssh-add ~/.ssh/id_rsa
$ TARGET=$(terraform output -json | jq -r .ipv4_address.value)
$ ssh root@$TARGET
```

5. Ensure NGINX is running and listening as expected :

```
$ netstat -tlp | grep -i nginx
tcp        0      0 0.0.0.0:http            0.0.0.0:*               LISTEN      2427/nginx: master  
tcp6       0      0 [::]:http               [::]:*                  LISTEN      2427/nginx: master  
```

```
$ systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Wed 2024-12-04 08:31:06 UTC; 2min 1s ago
 Invocation: 9e69ea812162426f8532fda20b1372ae
       Docs: man:nginx(8)
    Process: 2424 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 2425 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 2427 (nginx)
      Tasks: 2 (limit: 1110)
     Memory: 2M (peak: 2.5M)
        CPU: 22ms
     CGroup: /system.slice/nginx.service
             ├─2427 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             └─2428 "nginx: worker process"
```


5. Destroy the Infrastructure-as-Code with Terraform :

```
$ terraform destroy -var "do_token=$DO_TOKEN"
```
