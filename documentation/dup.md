dup CLI
=======

The dup command line interface provides a lot of different subcommands. Run `dup -h` to get a list of the available commands.


Installation
------------

To install the global dup command copy or symlink `path_to_dup/shell/cli/dup` to `/usr/local/bin/dup` (or some other location within your `$PATH`).


Usage
-----

Change to a directory where `dup` can find the folder containing all dup related files (e.g. the directory of your Vagrantfile).


Core commands
-------------

- `config`: Display the configuration entry for the given key path (e.g. `dup config vagrant.vm.ip`)
- `help`: Print the help
- `is_guest`: Print "yes" if the current machine is the guest, otherwise "no"
- `is_host`: Print "yes" if the current machine is the host, otherwise "no"
- `list_commands`: List the available commands
- `list_plugins`: List the available plugins
- `selfupdate`: Update the dup related files
- `version`: Print installed version


Plugins
-------

dup comes with a lot of plugins installed. (Run `dup list_plugins` to get a complete list).

Below is a list of the most important plugins:

- `app`: Manage packages installed on the system
- `mysql`: Connect to the database using the credentials from the env (`$DB_USERNAME`, `$DB_PASSWORD`, `$DB_NAME`, `$DB_HOST`)
- `service`: Manage services on the system
- `ssh`: Connect to the development machine through SSH
- `vagrant`: Aliases for various Vagrant commands
