class python::gunicorn::install(
  $virtualenv = $python::gunicorn::virtualenv,
) {

  python::pip { 'gunicorn':
    ensure     => present,
    virtualenv => $virtualenv,
  }

}
