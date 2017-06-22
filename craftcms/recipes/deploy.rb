Chef::Log.info("-- DEPLOY START")

def deploy_website(app, site_user)
    Chef::Log.info("-- deploy web site app_id: " + app['app_id'])
    Chef::Log.info("-- site user " + site_user)
    user 'create_user' do
        comment site_user
        username site_user
        group 'www-data'
        manage_home true
        home '/home/' + site_user
        shell '/bin/bash'
    end
end

search("aws_opsworks_command").each do |command|
  Chef::Log.info("*** command: " + command.inspect)
end

op_command = search("aws_opsworks_command").first
if op_command['type'] == 'deploy'
    site_user = app['environment']['SITE_USER']
    # list the hosts
    Chef::Log.info("HOSTS:")
    search("aws_opsworks_instance").each do |instance|
        Chef::Log.info(" -- instance:" + instance.inspect)
    end
    # list the apps
    Chef::Log.info("APPS:")
    search("aws_opsworks_app").each do |app|
        op_command['args']['app_ids'].each do |app_id|
            if app_id == app['app_id']
                deploy_website(app, site_user)
            end
        end
    end
end     

app = search("aws_opsworks_app").first

data_source = app['data_sources'][0]
rds_instance = search("aws_opsworks_rds_db_instance").first

Chef::Log.info("RDS info=#{rds_instance.inspect}")
Chef::Log.info("App: '#{app['shortname']}''")
Chef::Log.info("App URL: '#{app['app_source']['url']}'")
Chef::Log.info("App node: '#{app.inspect}'")

user 'create_user' do
    comment 'realise'
    username app_domain_name
    group app_domain_name
    manage_home true
    home '/home/' + app_domain_name
    shell '/bin/bash'
end

application '/srv/app' do
    # check out code
    git "/srv/app" do
        repository app['app_source']['url']
        reference 'master'
        action :sync
        deploy_key app["app_source"]["ssh_key"]
    end   
end

link '/var/www/html' do
  to '/srv/app/craftcms/public'
end

directory '/srv/app' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  recursive true
end

template "/srv/app/craftcms/craft/config/db.php" do
  source "db.php.erb"
  mode 0660

  variables(
    :host =>     (rds_instance[:address]),
    :user =>     (rds_instance[:db_user]),
    :password => (rds_instance[:db_password]),
    :database_name =>  (data_source[:database_name])      
  )
end

template "/srv/app/craftcms/craft/config/general.php" do
  source "general.php.erb"
  mode 0660

  variables(
    :site_url =>     (app['domains'][0] rescue nil),      
  )
end

template "/srv/app/craftcms/public/.htaccess" do
  source "htaccess.erb"
  mode 0660
end

execute "remove htaccess file" do
    action :run
    command "rm -f  /srv/app/craftcms/public/htaccess"
end

execute "update owner permission" do
    action :run
    command "chown -R www-data /srv/app"
end

execute "update group permission" do
    action :run
    command "chgrp -R www-data /srv/app"
end

Chef::Log.info("-- DEPLOY COMPLETE")