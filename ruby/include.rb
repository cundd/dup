dir = File.dirname(File.expand_path(__FILE__))

# Define the global variable TEST
if !defined? TEST
    TEST = false;
end

require "#{dir}/deep_merge.rb"
require "#{dir}/config.rb"
require "#{dir}/script_runner.rb"
require "#{dir}/package_installer.rb"
require "#{dir}/service.rb"
require "#{dir}/hostname.rb"
require "#{dir}/forwarded_ports.rb"
require "#{dir}/dup_vagrant.rb"
