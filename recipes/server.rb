#
# Cookbook Name:: monitor
# Recipe:: server
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

include_recipe "sensu::rabbitmq"
include_recipe "sensu::redis"

include_recipe "sensu::default"

sensu_handler "debug" do
  type "pipe"
  command "cat"
end

sensu_handler "default" do
  type "set"
  handlers node["monitor"]["default_handlers"]
end

sensu_handler "metrics" do
  type "set"
  handlers node["monitor"]["metric_handlers"]
end

include_recipe "sensu::server_service"
include_recipe "sensu::api_service"
include_recipe "sensu::dashboard_service"
