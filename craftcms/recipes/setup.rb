Chef::Log.info("-- SETUP START")

include_recipe "apache2"
include_recipe "apt"

apt_update 'update' do
  action :update
end

apache_site "default" do
    enable true
end

package ['php7.0', 'php-mbstring', 'php-mysql', 'php-curl', 'imagemagick php-imagick', 'php-mcrypt', 'libphp7']

directory '/var/www/html' do
  action :delete
end

link '/var/www/html' do
  to '/srv/app/public'
end

Chef::Log.info("-- SETUP COMPLETE")