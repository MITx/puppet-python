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
# [*dir*]
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
#   ensure      => present,
#   virtualenv  => '/var/www/project1',
#   mode        => 'wsgi',
#   dir         => '/var/www/project1/current',
#   bind        => 'unix:/tmp/gunicorn.socket',
#   environment => 'prod',
# }
#
# === Authors
#
# Sergey Stankevich
#
define python::gunicorn (
  $reporting,
  $ensure             = present,
  $virtualenv         = false,
  $mode               = 'wsgi',
  $dir                = false,
  $bind               = false,
  $environment        = false,
  $settings_module    = undef,
  $port               = '8000',
  $pre_start_commands = [],
  $package_root       = '/opt/wwc/mitx',
  $app_interface      = 'django',
  $wsgi_app           = undef,
  $timeout            = '30',
  $workers            = undef,
  $upstart_template   = template('python/gunicorn/gunicorn.conf.erb'),
) {

  class { 'python::gunicorn::install':
    virtualenv => $virtualenv,
  }

  # Parameter validation
  if ! $dir {
    fail('python::gunicorn: dir parameter must not be empty')
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
    ensure   => running,
    provider => 'upstart',
    require  => File["/etc/init/${name}.conf"],
    tag      => release
  }

}
