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

directory '/var/www/html' do
  action :delete
  recursive true
end

link '/var/www/html' do
  to '/srv/app/public'
end

directory '/srv/app' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
end

Chef::Log.info("-- SETUP COMPLETE")