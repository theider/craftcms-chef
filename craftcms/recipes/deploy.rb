Chef::Log.info("-- DEPLOY START")

app = search("aws_opsworks_app").first
rds_instance = search("aws_opsworks_rds_db_instance").first
environment_vars = search("site_url").first
Chef::Log.info("RDS info=#{rds_instance.inspect}")

Chef::Log.info("App: '#{app['shortname']}''")
Chef::Log.info("App URL: '#{app['app_source']['url']}'")

Chef::Log.info("App node: '#{app.inspect}'")

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
  to '/srv/app/public'
end

directory '/srv/app' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  recursive true
end

template "/srv/app/craft/config/db.php" do
  source "db.php.erb"
  mode 0660

  variables(
    :host =>     (rds_instance[:address] rescue nil),
    :user =>     (rds_instance[:db_user] rescue nil),
    :password => (rds_instance[:db_password] rescue nil),
    :db =>       ('timothyheider')      
  )
end

template "/srv/app/craft/config/general.php" do
  source "general.php.erb"
  mode 0660

  variables(
    :site_url =>     (environment_vars[:site_url] rescue nil),      
  )
end

template "/srv/app/public/.htaccess" do
  source "htaccess.erb"
  mode 0660
end

execute "remove htaccess file" do
    action :run
    command "rm -f  /srv/app/public/htaccess"
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