#
# Cookbook Name:: cookbook-openstack-dnsaas
# Recipe:: rabbitmq
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'rabbitmq::default'

bash "Create designate RabbitMQ user" do
  user "root"
  cwd "/tmp"
  creates "/etc/rabbitmq/.rabbitmq-prep1"
  code <<-EOH
     STATUS=0
     rabbitmqctl add_user designate designate || STATUS=1
     rabbitmqctl set_permissions -p "/" designate ".*" ".*" ".*"  || STATUS=1
     touch /etc/rabbitmq/.rabbitmq-prep1 || STATUS=1
     exit $STATUS
   EOH
end

service "rabbitmq-server" do
  supports :status => true, :restart => true, :truereload => true
  action [ :enable, :start ]
end
