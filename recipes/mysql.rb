#
# Cookbook Name:: gerrit
# Recipe:: mysql
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

include_recipe "mysql::client"
include_recipe "mysql::server"
include_recipe "database::mysql"

# When using MySql as a db for Gerrit, the Gerrit documentation recommends changing the db charset
# to latin1, in order to allow 1000 byte keys using the default MySQL MyISAM engine.  This can lead
# to spurious errors from Gerrit regarding "Illegal mix of collations".  We can avoid this by being
# explicit to the connector about which charset to use, by setting database.url in gerrit.config.
#
# One may use utf8 and avoid the key length limitation by switching to InnoDB, though we don't want
# to assume this choice.
node.set['gerrit']['config']['database']['url'] =
"jdbc:mysql://#{node['gerrit']['config']['database']['hostname']}:3306" +
    "/#{node['gerrit']['config']['database']['database']}?" +
    "user=#{node['gerrit']['config']['database']['username']}&" +
    "password=#{node['gerrit']['config']['database']['password']}&" +
    "useUnicode=false&characterEncoding=latin1"

# TODO I'm yet unsure, how to handle this in the future

# if this is set, an entry in the ssl_certificates data bag matching the given name must exist
# this uses the ssl-certificates cookbook
# http://github.com/binarymarbles/chef-ssl-certificates

node.set['mysql']['bind_address'] = "127.0.0.1"

# TODO delete other occurrences of this file
# the version can be found in gerrit-pgm/src/main/resources/com/google/gerrit/pgm/libraries.config
remote_file "#{node['gerrit']['install_dir']}/lib/mysql-connector-java-5.1.21.jar" do
  source "http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar"
  checksum "7abbd19fc2e2d5b92c0895af8520f7fa30266be9"
  owner node['gerrit']['user']
  group node['gerrit']['group']
end

mysql_connection_info = {
  :host =>  node['mysql']['bind_address'],
  :username => "root",
  :password => node['mysql']['server_root_password']
}

mysql_database node['gerrit']['config']['database']['database'] do
  connection mysql_connection_info
  action :create
end

mysql_database "changing the charset of database" do
  connection mysql_connection_info
  database_name node['gerrit']['config']['database']['database']
  action :query
  sql "ALTER DATABASE #{node['gerrit']['config']['database']['database']} charset=latin1"
end

mysql_database_user node['gerrit']['config']['database']['username'] do
  username node['gerrit']['config']['database']['username']
  connection mysql_connection_info
  database_name node['gerrit']['config']['database']['database']
  password node['gerrit']['config']['database']['password']
  privileges [
    :all
  ]
  action :grant
end

mysql_database "flushing mysql privileges" do
  connection mysql_connection_info
  action :query
  sql "FLUSH PRIVILEGES"
end
