#
# Cookbook Name:: database
# Recipe:: default

#
# Cookbook Name: database
# Recipe: default
#
# Description:
# Configure application servers to use mysql2 adapter for the database.yml config.
# All parameters except the adapter are pulled from the EY node JSON element. See
# http://docs.engineyard.com/use-deploy-hooks-with-engine-yard-cloud.html for an
# example of the node JSON object. This object is also used for by deploy hooks
# at Engine Yard.
#
# This file should be in .../cookbooks/database/recipes/default.rb
#
#
# Q: Why do we need this custom recipe?
#
# A: We needed to generate our own database.yml file because Engine Yard's default
# database.yml file generator always generates a config file that uses the mysql
# adapter for Rails 2 apps and always uses the mysql2 adapter for Rails 3 apps.
#
# In our case we needed to use the mysql2 adapter with our existing Rails 2 app.
#
# Apps using a replicated DB setup on EY may also need a custom Chef recipe to
# generate a database.yml
#
 
if ['solo', 'app_master', 'app', 'util'].include?(node[:instance_role])
  # for each application
  node[:engineyard][:environment][:apps].each do |app|
 
    # create new database.yml
    template "/data/#{app[:name]}/shared/config/database.yml" do
      source 'database.yml.erb'
      owner node[:users][0][:username]
      group node[:users][0][:username]
      mode 0644
      variables({
        :environment => node[:environment][:framework_env],
        :adapter => 'postgresql',
        :database => app[:database_name],
        :username => node[:users][0][:username],
        :password => node[:users][0][:password],
        :host => node[:db_host],
        :pool => 30
      })
    end
  end
end
