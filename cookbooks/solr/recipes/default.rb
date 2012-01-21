#
# Cookbook Name:: solr
# Recipe:: default
#
# We specify what version we want below.
solr_desiredversion = 1.4
if ['solo', 'util'].include?(node[:instance_role])
  if solr_desiredversion == 1.3
    solr_file = "apache-solr-1.3.0.tgz"
    solr_dir = "apache-solr-1.3.0"
    solr_url = "http://mirror.its.zuidaho.edu/pub/apache/lucene/solr/1.3.0/apache-solr-1.3.0.tgz"
  else
    solr_dir = "apache-solr-1.4.1"
    solr_file = "apache-solr-1.4.1.tgz"
    solr_url = "http://s3.amazonaws.com/slimkicker_solr/apache-solr-1.4.1.tgz"
  end

   directory "/var/run/solr" do
    action :create
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
  end

  directory "/var/log/engineyard/solr" do
    action :create
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
    recursive true
  end

  template "/engineyard/bin/solr" do
    source "solr.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
  variables({
    :rails_env => node[:environment][:framework_env]
  })
  end

  template "/etc/monit.d/solr.monitrc" do
    source "solr.monitrc.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
    variables({
      :user => node[:owner_name],
      :group => node[:owner_name]
    })
  end

   execute "delete-solr_folders" do
     command "rm -rf /data/solr && mkdir /data/solr"
   end

   execute "delete-apache-folders" do
     command "rm -rf /data/apache-solr-1.4.1  && rm -rf /data/apache-solr-1.4.1.tgz"
   end

  remote_file "/data/#{solr_file}" do
    source "#{solr_url}"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
    backup 0
  end

  execute "unarchive solr-to-install" do
    command "cd /data && tar zxf #{solr_file} && sync"
  end

  execute "install solr example package" do
    command "cd /data/#{solr_dir} && mv /data/apache-solr-1.4.1/example/* /data/solr"
  end

   directory "/data/solr" do
    action :create
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
  end

   execute "chown_solr" do
     command "chown #{node[:owner_name]}:#{node[:owner_name]} -R /data/solr"
   end

   execute "monit-reload" do
     command "monit quit && telinit q"
   end

   execute "start-solr" do
     command "sleep 3 && monit start solr_9080"
   end
   
   execute "import-foods" do
     command "curl http://localhost:8983/solr/core0/dataimport?command=full-import"
   end
   
   execute "import-exercises" do
     command "curl http://localhost:8983/solr/core1/dataimport?command=full-import"
   end

end
