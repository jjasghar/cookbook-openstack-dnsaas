#
# Cookbook Name:: designate
# Recipe:: mysql
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


%w{mysql-server-5.5 libmysqlclient-dev}.each do |pkg|
  package pkg do
    action [:install]
  end
end

mysql_database 'designate' do
  connection(
    :host     => '127.0.0.1',
    :username => 'deignate',
    :password => 'deignate'
  )
  action :create
end

mysql_database 'designate_pool_manager' do
  connection(
    :host     => '127.0.0.1',
    :username => 'deignate',
    :password => 'deignate'
  )
  action :create
end

bash "pip install mysql-python" do
  user "root"
  cwd "/var/lib/designate"
  creates "/var/lib/designate/.mysql_python_deps_installed"
  code <<-EOH
    STATUS=0
    . .venv/bin/activate || STATUS=1
    pip install mysql-python
    touch /var/lib/designate/.mysql_python_deps_installed || STATUS=1
    exit $STATUS
  EOH
end

bash "secure_mysql_instance" do
  user "root"
  cwd "/tmp"
  creates "/etc/mysql/.secure-mariadb"
  code <<-EOH
     STATUS=0
     mysql -e "DROP USER ''@'localhost'"
     mysql -e "DROP USER ''@'$(hostname)'"
     mysql -e "DROP DATABASE test"
     mysql -e "FLUSH PRIVILEGES"
     mysqladmin -u root password designate
     touch /etc/mysql/.secure-mariadb || STATUS=1
     exit $STATUS
   EOH
end

service "mysql" do
  supports :status => true, :restart => true, :truereload => true
  action [ :enable, :start ]
end
