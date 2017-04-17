Chef::Log.info("-- DEPLOY START")

app = search("aws_opsworks_app").first
rds_instance = search("aws_opsworks_rds_db_instance").first

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

Chef::Log.info("-- DEPLOY COMPLETE")