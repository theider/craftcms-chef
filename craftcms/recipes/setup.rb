Chef::Log.info("-- SETUP START")

include_recipe "apache2"
include_recipe "apt"

apt_update 'update' do
  action :update
end

apache_site "default" do
    enable true
end

package ['php7.0']

Chef::Log.info("-- SETUP COMPLETE")