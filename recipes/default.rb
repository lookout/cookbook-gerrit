#
# Cookbook Name:: gerrit
# Recipe:: default
#
# Copyright 2012, Steffen Gebert / TYPO3 Association
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

include_recipe "git"
include_recipe "java"

include_recipe "gerrit::_system"
include_recipe "gerrit::_config"
include_recipe "gerrit::_database"

if node['gerrit']['proxy']['enable']
  include_recipe "gerrit::proxy"
else
  node.set['gerrit']['config']['httpd']['listenUrl'] = 'http://*:8080'
end

include_recipe "gerrit::_deploy"
include_recipe "gerrit::_replication"

if node['gerrit']['peer_keys']['enabled']
  include_recipe "gerrit::peer_keys"
end

if node['gerrit']['batch_admin_user']['enabled']
  include_recipe "gerrit::batch_admin"
end

service "gerrit" do
  supports :status => false, :restart => true, :reload => true
  action [ :enable, :start ]
end
