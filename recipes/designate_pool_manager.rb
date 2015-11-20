#
# Cookbook Name:: cookbook-openstack-dnsaas
# Recipe:: designate_pool_manager
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

template "/etc/init.d/designate-pool-manager" do
  source "designate-pool-manager.init.d.erb"
  owner "root"
  group "root"
  mode "0755"
end

bash "sync Pool Managers cache" do
  user "root"
  cwd "/var/lib/designate"
  code <<-EOH
    STATUS=0
    source .venv/bin/activate || STATUS=1
    designate-manage pool-manager-cache sync || STATUS=1
    exit $STATUS
  EOH
end

service "designate-pool-manager" do
  supports :status => true, :restart => true, :truereload => true
  action [ :enable, :start ]
end
