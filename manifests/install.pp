class python::install {

  $python = $python::version ? {
    'system' => 'python',
    default  => "python${python::version}",
  }

  package { $python: ensure => present }

  $dev_ensure = $python::dev ? {
    true    => present,
    default => absent,
  }

  package { "${python}-dev": ensure => $dev_ensure }

  $venv_ensure = $python::virtualenv ? {
    true    => present,
    default => absent,
  }

  package { 'python-virtualenv': ensure => $venv_ensure }

}
