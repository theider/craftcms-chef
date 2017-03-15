#
# Cookbook Name:: php5-mysql
# Recipe:: default
#
# Copyright 2015, Yuriy Chernyshev
#
# Licensed under the MIT License.
# You may obtain a copy of the License at
#
#     http://opensource.org/licenses/MIT
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node[:platform]
when "ubuntu","debian"
	include_recipe "php"

	package "php5-mysql" do
	  package_name "php5-mysql"
	  action :install
	end
end