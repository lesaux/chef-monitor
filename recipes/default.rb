#
# Cookbook Name:: monitor
# Recipe:: default
#
# Copyright 2012, Sean Porter Consulting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.set.sensu.use_embedded_ruby = true

unless Chef::Config[:solo]
  monitor_server = search(:node, "recipes:monitor\:\:server").first

  unless monitor_server.nil?
    address = if monitor_server.has_key?("cloud")
      monitor_server["cloud"]["public_ipv4"] || monitor_server["ipaddress"]
    else
      monitor_server["ipaddress"]
    end
    node.set.sensu.rabbitmq.host = address
    node.set.sensu.redis.host = address
  end
end

include_recipe "sensu::default"

sensu_client node.name do
  if node.has_key?("cloud")
    address node["cloud"]["public_ipv4"] || node["ipaddress"]
  else
    address node["ipaddress"]
  end
  subscriptions node["roles"] + ["all"]
end

sensu_gem "sensu-plugin" do
  version node["monitor"]["sensu_plugin_version"]
end

cookbook_file "/etc/sensu/plugins/check-procs.rb" do
  source "plugins/check-procs.rb"
  mode 0755
end

include_recipe "sensu::client_service"
