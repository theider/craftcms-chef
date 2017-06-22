Chef::Log.info("-- SETUP START")

include_recipe "apache2"
include_recipe "apt"

apt_update 'update' do
  action :update1
end

apache_site "default" do
    enable true
end

package ['php7.0', 'php-mbstring', 'php-mysql', 'php-curl', 'php-xml', 'php-simplexml', 'imagemagick php-imagick', 'php-mcrypt', 'libapache2-mod-php']

template "/etc/apache2/apache2.conf" do
  source "apache2.conf.erb"
  mode 0660
end

apache_module "rewrite" do
  enable true
end

directory '/var/www/html' do
  action :delete
  recursive true
end

service "apache2" do
  action :restart
end

Chef::Log.info("-- SETUP COMPLETE")