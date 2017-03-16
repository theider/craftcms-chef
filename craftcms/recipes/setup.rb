Chef::Log.info("-- SETUP START")

include_recipe "apache2"
include_recipe "apt"

apt_update 'update' do
  action :update
end

apache_site "default" do
    enable true
end

package ['php7.0', 'php-mbstring', 'php-mysql', 'php-curl', 'imagemagick php-imagick', 'php-mcrypt']

# check out code
git "/home/ubuntu" do
    repository app['app_source']['url']
    reference 'master'
    action :sync
    deploy_key app["app_source"]["ssh_key"]
end

Chef::Log.info("-- SETUP COMPLETE")