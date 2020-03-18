# Get datadog major as input variable
datadog_version = input('version')

if os.debian?
  describe apt('https://apt.datadoghq.com') do
    it { should exist }
    it { should be_enabled }
  end
elsif os.redhat?
  describe yum.repo('datadog') do
    it { should exist }
    it { should be_enabled }
    its('baseurl') { should include 'yum.datadoghq.com' }
  end
end

describe user('dd-agent') do
  it { should exist }
  its('group') { should eq 'dd-agent' }
end

describe package('datadog-agent') do
  it { should be_installed }
end

describe service('datadog-agent') do
  it { should be_enabled }
  it { should be_running }
end

if datadog_version >= 6
  describe port(5001) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
    its('processes') { should include 'agent' }
  end
end

if datadog_version == 5
  describe file('/etc/dd-agent/datadog.conf') do
    it { should be_file }
    its('owner') { should eq 'dd-agent' }
    its('group') { should eq 'dd-agent' }
  end

  describe file('/etc/dd-agent/conf.d') do
    it { should be_directory }
    its('owner') { should eq 'dd-agent' }
    its('group') { should eq 'dd-agent' }
  end
else
  describe file('/etc/datadog-agent/datadog.yaml') do
    it { should be_file }
    its('owner') { should eq 'dd-agent' }
    its('group') { should eq 'dd-agent' }
  end

  describe file('/etc/datadog-agent/conf.d') do
    it { should be_directory }
    its('owner') { should eq 'dd-agent' }
    its('group') { should eq 'dd-agent' }
  end
end

