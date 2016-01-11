dup
===

Usage
-----

Import the Alpine Linux box (only has to be done once)
```bash
vagrant box add dupal https://github.com/cundd/vagrant-boxes/releases/download/0.1.0/alpine-3.3.0-x86_64.box
```

Clone the dup repository and change into the folder
```bash
git clone https://git.iresults.li/git/COD/dup.git project-url.local
cd project-url.local
```

Configure the VM in `dup/config.yaml`
```yaml
vagrant:
    vm:
        ip: "192.168.200.10" # <- Change this
```



Start the VM
```bash
vagrant up
```
