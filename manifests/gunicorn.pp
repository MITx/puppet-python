# == Define: python::gunicorn
#
# Manages Gunicorn virtual hosts.
#
# === Parameters
#
# [*ensure*]
#  present|absent. Default: present
#
# [*virtualenv*]
#  Run in virtualenv, specify directory. Default: disabled
#
# [*mode*]
#  Gunicorn mode.
#  wsgi|django. Default: wsgi
#
# [*package_root*]
#  Application directory.
#
# [*bind*]
#  Bind on: 'HOST', 'HOST:PORT', 'unix:PATH'.
#  Default: system-wide: unix:/tmp/gunicorn-$name.socket
#           virtualenv:  unix:${virtualenv}/${name}.socket
#
# [*environment*]
#  Set ENVIRONMENT variable. Default: none
#
# === Examples
#
# python::gunicorn { 'vhost':
#   ensure                    => present,
#   virtualenv                => '/var/www/project1',
#   mode                      => 'wsgi',
#   package_root              => '/var/www/project1/current',
#   bind                      => 'unix:/tmp/gunicorn.socket',
#   environment               => 'prod',
# }
#
# === Authors
#
# Sergey Stankevich
#
define python::gunicorn (
  $reporting,
  $app_interface      = 'django',
  $base               = '/opt/wwc',
  $bind               = false,
  $ensure             = present,
  $environment        = false,
  $mode               = 'wsgi',
  $package_root       = '/opt/wwc/mitx',
  $port               = '8000',
  $pre_start_commands = [],
  $respawn_limit      = false,
  $script_name        = '',
  $service_enabled    = 'present',
  $settings_module    = undef,
  $timeout            = '30',
  $upstart_template   = template('python/gunicorn/gunicorn.conf.erb'),
  $user               = 'www-data',
  $virtualenv         = false,
  $workers            = undef,
  $wsgi_app           = undef,
) {

  class { 'python::gunicorn::install':
    virtualenv => $virtualenv,
  }

  file { "/etc/init/${name}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['python::gunicorn::install'],
    notify  => Service[$name],
    content => $upstart_template,
  }

  service { $name:
    ensure   => $service_enabled,
    provider => 'upstart',
    require  => File["/etc/init/${name}.conf"],
    tag      => release
  }

}
