trigger {'refresh load balancers':
  hosts    => ['lb01.example.com', 'lb02.example.com'],
  provider => 'dummy',
}

exec {'/usr/bin/touch /tmp/foo':
  notify => Trigger['refresh load balancers'],
}

