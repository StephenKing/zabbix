# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: mysql_setup
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

# Execute apache2 receipe + mod_php5 receipe
include_recipe "apache2"
include_recipe "apache2::mod_php5"

case "#{node.platform}"
when "ubuntu","debian"

  %w{ php5-mysql php5-gd }.each do |pck|
    package "#{pck}" do
      action :install
      notifies :restart, "service[apache2]"
    end
  end

when "redhat","centos","scientific"

  if node.platform_version.to_f < 6.0
    %w{ php53-mysql php53-gd php53-bcmath php53-mbstring }.each do |pck|
      package "#{pck}" do
        action :install
        notifies :restart, "service[apache2]"
      end
    end
  else
    %w{ php-mysql php-gd php-bcmath php-mbstring }.each do |pck|
      package "#{pck}" do
        action :install
        notifies :restart, "service[apache2]"
      end
    end
  end

end

# Link to the web interface version
link "#{node.zabbix.web_dir}" do
  to "#{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/frontends/php"
end

directory "#{node.zabbix.src_dir}/zabbix-#{node.zabbix.server.version}/frontends/php/conf" do
  owner "#{node.apache.user}"
  group "#{node.apache.group}"
  mode "0755"
  action :create
end


#install vhost for zabbix frontend
web_app "#{node.zabbix.web.fqdn}" do
  server_name "#{node.zabbix.web.fqdn}"
  server_aliases "zabbix"
  docroot "#{node.zabbix.web_dir}"
  only_if { "#{node.zabbix.web.fqdn}" != nil }
end  
