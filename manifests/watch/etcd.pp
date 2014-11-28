# == Class trigger::watch::etcd
#
# This defined type configures a node to watch etcd
# It runs puppet when a matching key is found
#
define trigger::watch::etcd (
  $trigger_hostname = $::fqdn,
  $etcdctl_cmd      = 'etcdctl',
  $etcdctl_prefix   = '/puppet_trigger/events/hosts',
  $run_cmd          = 'puppet agent --test',
  $interval         = '*',
  $user             = 'root'
  ){
  $etcd_key = "${etcdctl_prefix}/${trigger_hostname}"

  $cronjob = "${etcdcl_cmd} ls ${etcd_key} && ${run_cmd} && ${etcdcl_cmd} rm ${etcd_key}"

  cron { "watch etcd key ${etcd_key}":
    command => $cronjob,
    user    => $user,
    minute  => $interval,
  }
}
