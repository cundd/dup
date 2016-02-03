dup CLI
=======

The dup command line interface provides a lot of different subcommands. Run `dup -h` to get a list of the available commands.


Installation
------------

To install the global dup command copy or symlink `path_to_dup/shell/cli/dup` to `/usr/local/bin/dup` (or some other location within your `$PATH`).


Usage
-----

dup comes with a lot of plugins installed. (Run `dup list_plugins` to get a complete list).

Below is a list of the most important plugins:

- `app`: Manage packages installed on the system
- `mysql`: Connect to the database using the credentials from the env (`$DB_USERNAME`, `$DB_PASSWORD`, `$DB_NAME`, `$DB_HOST`)
- `service`: Manage services on the system
- `ssh`: Connect to the development machine through SSH
- `vagrant`: Aliases for various Vagrant commands
