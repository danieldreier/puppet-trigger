# == Class trigger::service
#
# This class is meant to be called from trigger
# It ensure the service is running
#
class trigger::service {

  service { $::trigger::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
