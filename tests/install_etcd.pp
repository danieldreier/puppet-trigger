class { 'trigger::install::etcd':
  discovery_url => pick($::etcd_discovery_url, 'https://discovery.etcd.io/839382947dc86deba05e2894723e98e7'),
  etcd_ip       => $::ipaddress_eth1
}
