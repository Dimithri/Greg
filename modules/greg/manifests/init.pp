# ----------------------------------------------------------------------------
#  Copyright 2005-2013 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# ----------------------------------------------------------------------------
#
# Class: greg 
#
# This class installs WSO2 GREG
#
# Parameters:
# version            => '4.6.0'
# offset             => 1,
# hazelcast_port     => 4100,
# config_db          => 'greg_config',
# maintenance_mode   => 'zero',
# depsync            => false,
# sub_cluster_domain => 'mgt',
# clustering         => true,
# owner              => 'root',
# group              => 'root',
# target             => '/mnt/',
# members            => {'elb2.wso2.com' => 4010, 'elb.wso2.com' => 4010 }
#
# Actions:
#   - Install WSO2 GREG
#
# Requires:
#
# Sample Usage:
#

class greg (
  $version            = '4.6.0',
  $sub_cluster_domain = undef,
  $members            = undef,
  $port_mapping       = undef,
  $offset             = 0,
  $hazelcast_port     = 5000,
  $config_db          = 'governance',
  $config_target_path = 'config/greg',
  $maintenance_mode   = true,
  $depsync            = false,
  $clustering         = false,
  $cloud              = true,
  $owner              = 'root',
  $group              = 'root',
  $target             = "/mnt/${server_ip}",
  #stratos params
  $stratos_instance_data_deployment =undef,
  
) inherits params {
  $deployment_code = 'greg'
  $carbon_version  = $version
  $service_code    = 'greg'
  $carbon_home     = "${target}/wso2${service_code}-${carbon_version}"
  $service_templates = $sub_cluster_domain ? {
    'mgt'    => [
      'conf/axis2/axis2.xml',
      'conf/carbon.xml',
      'conf/datasources/master-datasources.xml',
      'conf/registry.xml',
      'conf/tomcat/catalina-server.xml',
      'conf/user-mgt.xml',
      ],
    'worker' => [
      'conf/axis2/axis2.xml',
      'conf/carbon.xml',
      'conf/datasources/master-datasources.xml',
      'conf/registry.xml',
      'conf/tomcat/catalina-server.xml',
      'conf/user-mgt.xml',
      ],
    default => [
      'conf/axis2/axis2.xml',
      'conf/carbon.xml',
      'conf/datasources/master-datasources.xml',
      'conf/registry.xml',
      'conf/tomcat/catalina-server.xml',
      'conf/user-mgt.xml',
      ],
  }
  $common_templates = []
  tag($service_code)
  greg::clean { $deployment_code:
    mode   => $maintenance_mode,
    target => $carbon_home,
  }
  greg::initialize { $deployment_code:
    repo      => $package_repo,
    version   => $carbon_version,
    service   => $service_code,
    local_dir => $local_package_dir,
    target    => $target,
    mode      => $maintenance_mode,
    owner     => $owner,
    require   => Greg::Clean[$deployment_code],
  }
  greg::deploy { $deployment_code:
    security => true,
    owner    => $owner,
    group    => $group,
    target   => $carbon_home,
    require  => Greg::Initialize[$deployment_code],
  }
  greg::push_templates {
    $service_templates:
      target    => $carbon_home,
      directory => $deployment_code,
      require   => Greg::Deploy[$deployment_code];
    $common_templates:
      target    => $carbon_home,
      directory => 'commons',
      require   => Greg::Deploy[$deployment_code],
  }
#  greg::start { $deployment_code:
#    owner   => $owner,
#    target  => $carbon_home,
#    require => [
#      Greg::Initialize[$deployment_code],
#      Greg::Deploy[$deployment_code],
#      Push_templates[$service_templates],
#      Push_templates[$common_templates],
#      ],
#  }
 greg::push_host { $deployment_code:
    owner   => $owner,
    lb_ip  => "${load_balancer_ip}",
    mgt_host => "${stratos_instance_data_host_name}",
    wrk_host => "${stratos_instance_data_worker_host_name}",
    require => [
      Greg::Initialize[$deployment_code],
      Greg::Deploy[$deployment_code],
      Push_templates[$service_templates],
      Push_templates[$common_templates],
      ],
  }
}
