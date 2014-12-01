trigger {'refresh load balancers':
  hosts    => [ 'server1.boxnet',
                'server2.boxnet',
                'server3.boxnet', ],
  provider => 'etcd',
}

exec {'/usr/bin/touch /tmp/foo':
  notify => Trigger['refresh load balancers'],
}

