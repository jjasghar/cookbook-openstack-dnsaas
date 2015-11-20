#
# Cookbook Name:: cookbook-openstack-dnsaas
# Recipe:: designate_api
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

template "/etc/init.d/designate-api" do
  source "designate-api.init.d.erb"
  owner "root"
  group "root"
  mode "0755"
end

service "designate-api" do
  supports :status => true, :restart => true, :truereload => true
  action [ :enable, :start ]
end
