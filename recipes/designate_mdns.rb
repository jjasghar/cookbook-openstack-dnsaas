#
# Cookbook Name:: cookbook-openstack-dnsaas
# Recipe:: designate_mdns
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

template "/etc/init.d/designate-mdns" do
  source "designate-mdns.init.d.erb"
  owner "root"
  group "root"
  mode "0755"
end

service "designate-mdns" do
  supports :status => true, :restart => true, :truereload => true
  action [ :enable, :start ]
end
