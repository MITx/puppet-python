# == Class: python
#
# Installs and manages python, python-dev, python-virtualenv and Gunicorn.
#
# === Parameters
#
# [*version*]
#  Python version to install. Default: system default
#
# [*dev*]
#  Install python-dev. Default: false
#
# [*virtualenv*]
#  Install python-virtualenv. Default: false
#
# [*gunicorn*]
#  Install Gunicorn. Default: false
#
# === Examples
#
# class { 'python':
#   version    => 'system',
#   dev        => true,
#   virtualenv => true,
#   gunicorn   => true,
# }
#
# === Authors
#
# Sergey Stankevich
#
class python (
  $version    = 'system',
  $dev        = false,
  $virtualenv = false,
  $virtualenv_location = '/opt/edx',
  $gunicorn   = false
) {

  # Module compatibility check
  $compatible = [ 'Debian', 'Ubuntu' ]
  if ! ($::operatingsystem in $compatible) {
    fail("Module is not compatible with ${::operatingsystem}")
  }

  Class['python::install'] -> Class['python::config']

  include python::install
  include python::config

  # Move this to here so it gets installed a single time in the virtualenv.  If
  # we ever want to split into multiple venvs then this will move back to
  # gunicorn.pp and we'll enhance python::pip to take arguments so the name
  # can be unique and not cause clashes with multiple instances of the lms
  # define.
  python::pip { 'gunicorn':
    ensure     => present,
    virtualenv => $virtualenv_location,
    require    => Class['python::config'],
  }

}
