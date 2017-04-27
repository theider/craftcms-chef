Chef::Log.info("-- SETUP START")

include_recipe "apache2"
include_recipe "apt"

apt_update 'update' do
  action :update
end

apache_site "default" do
    enable true
end

package ['php7.0', 'php-mbstring', 'php-mysql', 'php-curl', 'imagemagick php-imagick', 'php-mcrypt', 'libapache2-mod-php']

apache_module "rewrite" do
  enable true
end

directory '/var/www/html' do
  action :delete
  recursive true
end

Chef::Log.info("-- SETUP COMPLETE")