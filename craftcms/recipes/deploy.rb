Chef::Log.info("-- DEPLOY START")

app = search("aws_opsworks_app").first

Chef::Log.info("App short name is '#{app['shortname']}''")
Chef::Log.info("App URL is '#{app['app_source']['url']}'")

application '/home/ubuntu' do
    # check out code
    git "/home/ubuntu" do
        repository app['app_source']['url']
        reference 'master'
        action :sync
        deploy_key app["app_source"]["ssh_key"]
    end
end

Chef::Log.info("-- DEPLOY COMPLETE")