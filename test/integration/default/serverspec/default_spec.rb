require 'spec_helper'

describe 'cookbook-openstack-dnsaas::default' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html
  it 'does something' do
    skip 'Replace this with meaningful tests'
  end

  describe port(53) do
    it { should be_listening }
  end

  describe port(9001) do
    it { should be_listening }
  end

  describe package('python-pip') do
    it { should be_installed }
  end

  describe package('python-virtualenv') do
    it { should be_installed }
  end

  describe package('git') do
    it { should be_installed }
  end

  describe package('sudo') do
    it { should be_installed }
  end

  describe file('/var/lib/designate') do
    it { should be_directory }
  end

  describe file('/var/lib/designate/.venv/bin/activate') do
    it { should be_file }
  end

  describe file('/var/log/designate') do
    it { should be_directory }
  end

  describe file('/etc/sudoers.d/90-designate') do
    it { should be_file }
  end

  describe file('/etc/init.d/designate-central') do
    it { should be_file }
  end

  describe service('designate-central') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('designate-api') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('designate-pool-manager') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('designate-mdns') do
    it { should be_enabled }
    it { should be_running }
  end


end
