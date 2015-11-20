#
# Cookbook Name:: designate
# Recipe:: mysql
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'apt'

%w{bind9}.each do |pkg|
  package pkg do
    action [:install]
  end
end

template "/etc/bind/named.conf.options" do
  source "named.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

bash "disable apparmor for BIND9" do
  user "root"
  cwd "/tmp"
  creates "/etc/apparmor.d/disable/usr.sbin.named"
  code <<-EOH
    STATUS=0
    touch /etc/apparmor.d/disable/usr.sbin.named || STATUS=1
    service apparmor reload
    exit $STATUS
  EOH
end

service "bind9" do
  supports :status => true, :restart => true, :truereload => true
  action [ :enable, :restart ]
end
