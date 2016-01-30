dup
===

Usage
-----

### Prepare your host (only has to be done once)

Import the Alpine Linux box

```bash
vagrant box add dupal https://github.com/cundd/vagrant-boxes/releases/download/0.1.0/alpine-3.3.0-x86_64.box
```

Install the Alpine Linux plugin

```bash
vagrant plugin install vagrant-alpine
```


### Project setup

Clone the dup repository and copy the Vagrant file

```bash
mkdir project-url.local;
cd project-url.local;
git clone https://git.iresults.li/git/COD/dup.git dup
mkdir httpdocs;
cp dup/Vagrantfile Vagrantfile;
cp dup/default-config.yaml config.yaml;
```

Configure the VM in `config.yaml`

```yaml
vagrant:
    vm:
        ip: "192.168.200.10" # <- Change this
```

Start the VM and enter the **host's** password when asked

```bash
dup vagrant::up
```
