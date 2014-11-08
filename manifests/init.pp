# == Class: trigger
#
# Full description of class trigger here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class trigger (
  $package_name = $::trigger::params::package_name,
  $service_name = $::trigger::params::service_name,
) inherits ::trigger::params {

  # validate parameters here

  class { '::trigger::install': } ->
  class { '::trigger::config': } ~>
  class { '::trigger::service': } ->
  Class['::trigger']
}
