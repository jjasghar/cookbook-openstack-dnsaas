#
# Cookbook Name:: cookbook-openstack-dnsaas
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'apt'

%w{python-pip python-virtualenv git sudo}.each do |pkg|
  package pkg do
    action [:install]
  end
end

bash "build the python-lxml deps" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    STATUS=0
    apt-get build-dep python-lxml -y || STATUS=1
    exit $STATUS
  EOH
end

git "/var/lib/designate" do
  repository "https://github.com/openstack/designate.git"
  reference "master"
  user "root"
  group "root"
  action :sync
end

bash "create the virtualenv" do
  user "root"
  cwd "/var/lib/designate"
  creates "/var/lib/designate/.virtualenv_created"
  code <<-EOH
    STATUS=0
    virtualenv --no-site-packages .venv || STATUS=1
    source .venv/bin/activate || STATUS=1
    touch /var/lib/designate/.virtualenv_created || STATUS=1
    exit $STATUS
  EOH
end

bash "install the python dependencies" do
  user "root"
  cwd "/var/lib/designate"
  creates "/var/lib/designate/.python_deps_installed"
  code <<-EOH
    STATUS=0
    source .venv/bin/activate || STATUS=1
    pip install -r requirements.txt -r test-requirements.txt || STATUS=1
    python setup.py develop || STATUS=1
    touch /var/lib/designate/.python_deps_installed || STATUS=1
    exit $STATUS
  EOH
end

bash "convert the sample files to real ones" do
  user "root"
  cwd "/var/lib/designate/etc/designate"
  creates "/var/lib/designate/.samples_created"
  code <<-EOH
    STATUS=0
    ls *.sample | while read f; do cp $f $(echo $f | sed "s/.sample$//g"); done || STATUS=1
    touch /var/lib/designate/.samples_created || STATUS=1
    exit $STATUS
  EOH
end

directory "/var/log/designate" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

template "/var/lib/designate/etc/designate/designate.conf" do
  source "designate.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

include_recipe 'designate::rabbitmq'
include_recipe 'designate::mysql'
include_recipe 'designate::bind9'

bash "add designate to sudoers" do
  user "root"
  cwd "/tmp"
  creates "/var/lib/designate/.designate_sudoers"
  code <<-EOH
    STATUS=0
    echo "designate ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/90-designate || STATUS=1
    chmod 0440 /etc/sudoers.d/90-designate || STATUS=1
    touch /var/lib/designate/.designate_sudoers || STATUS=1
    exit $STATUS
  EOH
end

bash "designate database sync" do
  user "root"
  cwd "/var/lib/designate/.designate_dbsync"
  creates ""
  code <<-EOH
    STATUS=0
    . .venv/bin/activate || STATUS=1
    designate-manage database sync || STATUS=1
    touch "/var/lib/designate/.designate_dbsync" || STATUS=1
    exit $STATUS
  EOH
end

template "/etc/init.d/designate-central" do
  source "designate-central.init.d.erb"
  owner "root"
  group "root"
  mode "0755"
end

service "designate-central" do
  supports :status => true, :restart => true, :truereload => true
  action [ :enable, :start ]
end

include_recipe 'designate::designate_api'
include_recipe 'designate::designate_pool_manager'
include_recipe 'designate::designate_mdns'
