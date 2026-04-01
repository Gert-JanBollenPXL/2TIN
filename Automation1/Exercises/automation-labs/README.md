# automation-labs

## Overview

Automated lab environment for PXL Labs. Spins up two AlmaLinux 9 VMs using Vagrant + Libvirt/KVM, with Ansible for configuration management. This repository contains:

- **initial-setup**: For starting the course
- **default-setup**: The primary setup for many exercises.

## Quick Start

```sh
git clone https://github.com/PXLAutomation/automation-labs.git
cd automation-labs
```

### Initial Set-up

Use this set-up for the initial lessons

```sh
cd initial-setup
vagrant up
```

### Default set-up

Use this set-up for most exercises.

```sh
cd default-setup
vagrant up
```

### Test Connectivity

Test whether Ansible can communicate with the default Vagrant hosts.

```sh
ansible all -i inventory.ini -m ping
```

- The built-in inventory group `all` targets every host in the inventory file.
- The built-in `ping` module verifies that Ansible can establish a connection via ssh and execute modules through python on the managed nodes.
  - It is not the same as the `ping` system network tool that works through ICMP.

*Expected Output:*

```json
[...]

webserver1.pxldemo.local | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

[...]
```

## VMs

Each VM has two network interfaces:

| Interface | Network               | Address              | Purpose              |
|-----------|-----------------------|----------------------|----------------------|
| eth0      | 192.168.121.0/24 (DHCP) | changes on every recreate | Vagrant management - used internally for SSH during provisioning, do not rely on this IP |
| eth1      | 10.10.0.0/24 (static) | see table above       | Lab network - stable across recreates, use this for everything |

The host machine is the gateway at `10.10.0.1` on the lab network and can reach both VMs directly by IP or hostname once `/etc/hosts` is updated.

| Name       | Hostname               | Private IP       | Forwarded port       |
|------------|------------------------|------------------|----------------------|
| webserver1 | webserver1.pxldemo.local | 10.10.0.10 | host:8080 -> guest:8080 |
| webserver2 (initial set-up only) | webserver1.pxldemo.local | 10.10.0.11 | host:8081 -> guest:8080 |
| dbserver1  | dbserver1.pxldemo.local | 10.10.0.20 | -                    |

VM-to-VM traffic (e.g. webserver1 -> dbserver1) travels over eth1 via the static IPs. Hostname resolution between VMs is handled by `/etc/hosts` on each guest, populated automatically on first `vagrant up`.

- Box: version-locked Almalinux (<https://almalinux.org>)
- Each VM: 2 GB RAM, 2 CPUs

## Credentials & Access

### SSH

```sh
vagrant ssh webserver1
vagrant ssh webserver2
vagrant ssh dbserver1
```

Vagrant uses the **shared insecure private key** (`~/.vagrant.d/insecure_private_key`) for all VMs. Host key checking is disabled. To SSH manually:

```sh
ssh -i ~/.vagrant.d/insecure_private_key -p 2222 vagrant@127.0.0.1  # webserver1
```

- **Username:** `vagrant`
- **Password:** `vagrant` (default for all Vagrant boxes)
- **Sudo:** passwordless inside the VM (`vagrant` user has NOPASSWD sudo)

### `/etc/hosts` file

`vagrant up` automatically adds to both the **host machine** and each **guest VM**:

```text
10.10.0.10 webserver1.pxldemo.local webserver1
10.10.0.11 webserver2.pxldemo.local webserver2 (if initial-set-up is run)
10.10.0.20 dbserver1.pxldemo.local dbserver1
```

VMs can reach each other by hostname. From the host, you can use the static IPs or hostnames directly after the first `vagrant up`.

## Common Commands

```sh
vagrant up                                      # start all VMs
vagrant up webserver1                           # start one VM
vagrant status                                  # check state
vagrant ssh webserver1                          # shell into VM
vagrant destroy -f                              # destroy all VMs (clean)

ansible-playbook -i inventory.ini playbook.yml  # run Ansible playbook
```

## Cleanup

```sh
vagrant destroy -f
```

If `vagrant destroy` fails or leaves orphaned resources (e.g. after a crash):

```sh
./nuke_all_vagrant.sh            # dry run - shows what would be deleted
./nuke_all_vagrant.sh --force    # destroys ALL Vagrant environments and orphaned libvirt domains/volumes
```

The nuke script preserves base box images and ISOs.

## Ansible

`inventory.ini` connects directly to the VMs via their static private network IPs using the Vagrant insecure key. `ansible.cfg` disables host key checking.

```sh
ansible-playbook -i inventory.ini playbook.yml
```
