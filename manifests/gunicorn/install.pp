class python::gunicorn::install(
  $virtualenv,
) {

  python::pip { 'gunicorn':
    ensure     => present,
    virtualenv => $virtualenv,
  }

}
