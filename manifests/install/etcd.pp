# == Class trigger::install::etcd
#
# This installs etcd in a terrible hacky way
# not intended for production use, just to make development
# and demos easier.

class trigger::install::etcd (
  $hosts = [],
  $version = '0.4.6',
  $target = '/opt',
  $config_hash = {},
  $discovery_url = undef,
  $peers = [],
  $etcd_name = $::fqdn,
  $etcd_ip   = $::ipaddress,
  $data_dir = '/var/etcd/data'
  ){

  $osname   = downcase($::kernel)
  $filename = "etcd-v${version}-${osname}-${::architecture}.tar.gz"
  $url      = "https://github.com/coreos/etcd/releases/download/v${version}/${filename}"

  include archive::prerequisites
  archive { 'etcd':
    ensure           => present,
    url              => $url,
    target           => $target,
    #    src_target  => '/tmp',
    strip_components => 1,
    checksum         => false,
    notify           => Service['etcd']
  }
  file { ['/etc/etcd', '/var/etcd', '/var/etcd/data' ]:
    ensure => 'directory',
  }
  file { 'etcd.conf':
    path    => '/etc/etcd/etcd.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('trigger/install/etcd.conf.erb'),
    require => File['/etc/etcd'],
    notify  => Service['etcd']
  }
  file { 'etcd-init':
    path    => '/etc/init.d/etcd',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['etcd.conf'],
    content => template('trigger/install/etcd.debian-init.erb'),
    notify  => Service['etcd']
  }
  file { '/usr/local/bin/etcdctl':
    ensure  => 'link',
    target  => '/opt/etcd/etcdctl',
    require => Archive['etcd'],
  }

  service { 'etcd':
    ensure  => 'running',
    enable  => true,
    require => [File['etcd-init'], File['etcd.conf'], Archive['etcd'], File[$data_dir]],
  }

}
