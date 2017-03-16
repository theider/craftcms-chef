Chef::Log.info("-- DEPLOY START")

app = search("aws_opsworks_app").first
deploy_node = app["deploy"]

Chef::Log.info("deploy node=#{deploy_node.inspect}")

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

node[:deploy].each do |app_name, deploy|
  template "#{deploy[:deploy_to]}/current/db-connect.php" do
    source "db.php.erb"
    mode 0660
    group deploy[:group]

    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")   
      owner "apache"
    end

    variables(
      :host =>     (deploy[:database][:host] rescue nil),
      :user =>     (deploy[:database][:username] rescue nil),
      :password => (deploy[:database][:password] rescue nil),
      :db =>       (deploy[:database][:database] rescue nil)      
    )
  end
end

Chef::Log.info("-- DEPLOY COMPLETE")