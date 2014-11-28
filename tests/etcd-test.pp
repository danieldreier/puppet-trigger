trigger {'refresh load balancers':
  hosts    => ['lb01.example.com',
               'lb02.example.com',
               'lb03.example.com', ],
  provider => 'etcd',
  tag      => ['staging', 'lb', 'puppetlabs.com'],
}

exec {'/usr/bin/touch /tmp/foo':
  notify => Trigger['refresh load balancers'],
}

