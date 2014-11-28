# == Class trigger::watch::etcd
#
# This defined type configures a node to watch etcd
# It runs puppet when a matching key is found
#
class trigger::watch::dependencies {
  package { 'task-spooler':
    ensure => 'present',
  }
}
