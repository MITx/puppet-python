class python::config {

  Class['python::install'] -> Python::Pip <| |>
  Class['python::install'] -> Python::Requirements <| |>
  Class['python::install'] -> Python::Virtualenv <| |>

  Python::Virtualenv <| |> -> Python::Pip <| |>
  Python::Virtualenv <| |> -> Python::Requirements <| |>

}
