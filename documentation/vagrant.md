Vagrant setup
=============

Prepare your host (only has to be done once)
--------------------------------------------

If the Alpine Linux box "dupal" should be used import the box and install the Alpine Linux plugin.

Import the Alpine Linux box:

```bash
vagrant box add dupal https://github.com/cundd/vagrant-boxes/releases/download/0.1.0/alpine-3.3.0-x86_64.box
```

Install the Alpine Linux plugin:

```bash
vagrant plugin install vagrant-alpine
```


Project setup
-------------

Clone the dup repository and copy the Vagrant file

```bash
mkdir project-url.local;
cd project-url.local;
git clone https://github.com/cundd/dup.git dup
mkdir httpdocs;
cp dup/default-Vagrantfile.rb Vagrantfile;
cp dup/default-config.yaml config.yaml;
```

Configure the VM in `config.yaml`

```yaml
vagrant:
    vm:
        ip: "192.168.200.10" # <- Change this
```

Start the VM and enter the **host's** password when asked:

```bash
dup vagrant::up
```

The synced folders are shared through NFS because the Virtual Box Guest Additions are not available on Alpine. The type can be changed in the configuration `vagrnat.vm.share_type`.


Database provisioning
---------------------

Define the database configuration inside `config.yaml`.

The most important values are:

```yaml
scripts:
    ENV:
        DB_ROOT_PASSWORD: # <- Change the database root password
        DB_USERNAME: "client" # <- User name for the user database
        DB_NAME: "client" # <- User database name
        DB_PASSWORD: # <- Change the password for the user database
```

If a database dump should be imported when the database is created, place the `.sql` or `.sql.gz` file into `provision/vagrant/files/database/import/`
