# == Define: python::requirements
#
# Installs and manages Python packages from requirements file.
#
# === Parameters
#
# [*virtualenv*]
#  virtualenv to run pip in. Default: system-wide
#
# [*proxy*]
#  Proxy server to use for outbound connections. Default: none
#
# === Examples
#
# python::requirements { '/var/www/project1/requirements.txt':
#   virtualenv => '/var/www/project1',
#   proxy      => 'http://proxy.domain.com:3128',
# }
#
# === Authors
#
# Sergey Stankevich
#
define python::requirements (
  $virtualenv = 'system',
  $proxy      = false,
  $owner      = 'www-data',
  $group      = 'www-data',
) {

  $requirements = $name

  $pip_env = $virtualenv ? {
    'system' => '`/bin/which pip`',
    default  => "${virtualenv}/bin/pip",
  }

  $proxy_flag = $proxy ? {
    false    => '',
    default  => "--proxy=${proxy}",
  }

  $req_dir = inline_template('<%= requirements.match(%r!(.+)/.+!)[1] %>')
  $req_crc = "${requirements}.sha1"

  file { $requirements:
    ensure  => present,
    mode    => '0644',
    owner   => $owner,
    group   => $group,
    replace => false,
    content => '# Puppet will install and/or update pip packages listed here',
  }

  # SHA1 checksum to detect changes
  exec { "python_requirements_check_${name}":
    command => "sha1sum ${requirements} > ${req_crc}",
    unless  => "sha1sum -c ${req_crc}",
    require => File[$requirements],
  }

  exec { "python_requirements_update_${name}":
    command     => "${pip_env} install ${proxy_flag} -r ${requirements}",
    cwd         => $req_dir,
    refreshonly => true,
    timeout     => 3600,
    subscribe   => Exec["python_requirements_check_${name}"],
  }

}
