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

Clone the dup repository and change into the folder

```bash
git clone https://git.iresults.li/git/COD/dup.git project-url.local
cd project-url.local
```

Configure the VM in `config.yaml`

```yaml
vagrant:
    vm:
        ip: "192.168.200.10" # <- Change this
```

Start the VM and enter the **host's** password when asked

```bash
vagrant up
```
