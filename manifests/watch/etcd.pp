# == Class trigger::watch::etcd
#
# This class configures a node to watch etcd
# It runs puppet when a matching key is found
#
class trigger::watch::etcd (
  $trigger_hostname = $::fqdn,
  $etcdctl_cmd      = '/opt/etcd/etcdctl',
  $etcdctl_prefix   = '/puppet_trigger/events/hosts',
  $run_cmd          = 'puppet agent --test',
  $etcdwatch_pwd    = '/usr/local/bin/etcdwatch',
  ){
  include ::trigger::watch::dependencies

  $etcd_key = "${etcdctl_prefix}/${trigger_hostname}"

  file { 'etcdwatch':
    path    => $etcdwatch_pwd,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('trigger/watch/etcdwatch.sh.erb'),
    notify  => Service['etcdwatch']
  }
  file { 'etcdwatch-service':
    path    => '/etc/init.d/etcdwatch',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['etcdwatch'],
    content => template('trigger/watch/etcdwatch.debian-init.erb'),
    notify  => Service['etcdwatch']
  }
  service { 'etcdwatch':
    ensure  => 'running',
    enable  => true,
    require => [ File['etcdwatch-service'], File['etcdwatch'] ]
  }
}
