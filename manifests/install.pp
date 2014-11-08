# == Class trigger::install
#
class trigger::install {

  package { $::trigger::package_name:
    ensure => present,
  }
}
