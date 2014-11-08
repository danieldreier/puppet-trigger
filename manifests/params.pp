# == Class trigger::params
#
# This class is meant to be called from trigger
# It sets variables according to platform
#
class trigger::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'trigger'
      $service_name = 'trigger'
    }
    'RedHat', 'Amazon': {
      $package_name = 'trigger'
      $service_name = 'trigger'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
