template "#{node['gerrit']['install_dir']}/etc/replication.config" do
  source "gerrit/replication.config.erb"
  owner node['gerrit']['user']
  group node['gerrit']['group']
  mode 0644
end
