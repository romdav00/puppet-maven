# Copyright 2011 MaestroDev
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

# Define: maven::settings
#
# A puppet recipe to set the contents of the settings.xml file
#
#
# servers => [{
#   id,
#   username,
#   password
# },...]
#
# mirrors => [{
#   id,
#   url,
#   mirrorOf
# },...]
#
# properties => {
#   key=>value
# }
#
# repos => [{
#   id,
#   name, #optional
#   url,
#   releases => {
#     key=>value
#   },
#   snapshots=> {
#     key=>value
#   }
# },...]
#
# # Provided for backwards compatibility
# # A shortcut to essentially add the central repo to the above list of repos.
# default_repo_config => {
#   url,
#   releases => {
#     key=>value
#   },
#   snapshots=> {
#     key=>value
#   }
# }
#
# proxies => [{
#   active, #optional, default to true
#   protocol, #optional, defaults to http
#   host,
#   port,
#   username,#optional
#   password, #optional
#   nonProxyHosts #optional
# },...]
#
# profiles => {
# 'profile1' => { # <- this becomes the profile id
#   'activation' => {
#     'activeByDefault' => false,
#     'jdk' => '1.5',
#     'os' => {
#       'name' => 'Windows XP',
#       'family' => 'Windows',
#       'arch' => 'x86',
#       'version' => '5.1.2600'
#     },
#     'property' => {
#       'name' => 'mavenVersion',
#       'value' => '2.0.3'
#     },
#     'file' => {
#       'exists' => '${basedir}/file2.properties',
#       'missing' => '${basedir}/file1.properties'
#     }
#   },
#   'repositories' => {
#     'codehausSnapshots' => { # <- this becomes the repository id
#       'name' => 'Codehaus Snapshots',
#       'releases' => {
#         'enabled' => false,
#         'updatePolicy' => 'always',
#         'checksumPolicy' => 'warn'
#       },
#       'snapshots' => {
#         'enabled' => true,
#         'updatePolicy' => 'never',
#         'checksumPolicy' => 'fail'
#       },
#       'url' => 'http://snapshots.maven.codehaus.org/maven2',
#       'layout' => 'default'
#     }
#   },
#   'pluginRepositories' => {
#     'codehausSnapshots' => { # <- this becomes the repository id
#       'name' => 'Codehaus Snapshots',
#       'releases' => {
#         'enabled' => false,
#         'update_policy' => 'always',
#         'checksum_policy' => 'warn'
#       },
#       'snapshots' => {
#         'enabled' => true,
#         'updatePolicy' => 'never',
#         'checksumPolicy' => 'fail'
#       },
#       'url' => 'http://snapshots.maven.codehaus.org/maven2',
#       'layout' => 'default'
#     }
#   },
#   'properties' => {
#       'key1' => 'value1'
#   }
# }
#
# activeProfiles => [ 'profile1', 'profile2', ...]
#
define maven::settings($home = undef, $user = 'root', $group = 'root',
  $servers = [], $mirrors = [], $default_repo_config = undef, $repos = [],
  $properties = {}, $local_repo = '', $dir_mask = '700', $file_mask = '600',
  $proxies = [], $profiles = {}, $active_profiles = [], $master_password = undef) {

  if $home == undef {
    $home_real = $user ? {
      'root'  => '/root',
      default => "/home/${user}"
    }
  }
  else {
    $home_real = $home
  }

  file { "${home_real}/.m2":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => $dir_mask,
  }
  -> file { "${home_real}/.m2/settings.xml":
    owner   => $user,
    group   => $group,
    mode    => $file_mask,
    content => template('maven/settings.xml.erb'),
  }

  unless $master_password == undef {
    file { "${home_real}/.m2/settings-security.xml":
      owner   => $user,
      group   => $group,
      mode    => $file_mask,
      content => template('maven/settings-security.xml.erb'),
      require => File["${home_real}/.m2"],
    }
  }
}
