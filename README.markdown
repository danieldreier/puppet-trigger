#### Table of Contents

1. [Overview](#overview)
2. [What Trigger Does](#module-description)
3. [Setup - The basics of getting started with trigger](#setup)
    * [What trigger affects](#what-trigger-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with trigger](#beginning-with-trigger)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Proof-of-concept lightweight Puppet-native orchestration tool

## Module Description

Trigger provides orchestration primitives to allow cross-node notifications
to do things like:

```puppet
trigger {'refresh load balancers':
  hosts    => ['lb01.example.com', 'lb02.example.com'],
  provider => 'etcd',
}

haproxy::balancermember { 'haproxy':
  listening_service => 'webserver',
  ports             => '80',
  server_names      => $::hostname,
  ipaddresses       => $::ipaddress,
  options           => 'check',
  notify            => Trigger['refresh load balancers'],
}
```

At the moment, the only providers implemented are an etcd provider and a
"dummy" provider that does nothing. The goal is to add an mcollective
provider and possibly others. The etcd provider is pretty primitive, but
it does work.

## Vagrant Demo
To see it for yourself, there's a vagrant-based demo included in this repo.

1. Open `Vagrantfile` in your favorite editor
2. Visit [https://discovery.etcd.io/new](https://discovery.etcd.io/new)
3. Set `ETCD_DISCOVERY_URL` to the value you got from [discovery.etcd.io](https://discovery.etcd.io/new)
4. Run `bundle install ; rake build` (you may want to `rvm gemset use trigger --create` first)
5. Run `rake build` to create a puppet module package
6. run `vagrant up` and wait a few minutes for everything to finish
7. SSH into all three nodes at once in different windows.
8. As root, run `watch -n 1 tsp` on two nodes.
8. On the third node, `puppet apply /vagrant/tests/etcd-test.pp`
9. If everything was set up correctly, you'll see a `puppet agent` queue up in task spooler and execute

## How Trigger Works

Trigger gives you a `trigger` puppet resource type that represents other puppet
nodes, specified by the `hosts` parameter. Nothing happens when you declare it;
the only time actions happen is when you `notify => Trigger['the trigger']`
from another resource.

The specifics of how the provider causes Puppet to be run varies by provider,
but an agent run will start on each of the specified `hosts` whenever you
`notify` the `trigger` resource. Consequently, all of your orchestration logic
is (necessarily) in Puppet manifests. Trigger provides no execution ordering,
passes no additional data, etc. You can use exported resources, puppetdbquery,
[garethr/key_value_config](https://forge.puppetlabs.com/garethr/key_value_config),
or whatever you can come up with to coordinate data between the nodes.

### What trigger affects

* The etcd provider installs a service that watches etcd for keys
* Trigger can install etcd in a very minimal way
* That's about it

### Setup Requirements

The etcd provider uses [task-spooler](http://vicerveza.homeunix.net/~viric/soft/ts/)
to queue puppet runs, so that additional notifications during agent runs queue up.
TS isn't available on every platform, so you may run into issues there.

If you use the etcd provider, you (obviously) need to have etcd running before
trigger will do anything.

Note that there is no requirement to use a puppet master; trigger should
coordinate masterless nodes just fine. A master is convenient, but the vagrant
demo doesn't use one. If you go masterless, you'll need to override `run_cmd`:
```puppet
class { 'trigger::watch::etcd':
  run_cmd => 'puppet apply manifest.pp'
}
```

If you do use a master, you'll probably want to use puppetdb and Erik Dalén's
excellent [puppetdbquery](https://github.com/dalen/puppet-puppetdbquery) tool
to populate the `hosts` parameter on `trigger` resources you create, rather
than hard-coding in host names. For example, you might do something like:

```puppet
trigger {'refresh load balancers':
  hosts    => query_nodes(Class[Profile::Loadbalancer]', fqdn)
  provider => 'etcd',
}
```

This will populate hosts with an array of fqdns for nodes that use class
`profile::loadbalancer`.

### Beginning with trigger

## Usage

Start by defining a trigger:
```puppet
trigger {'refresh load balancers':
  hosts    => ['lb01.example.com', 'lb02.example.com'],
  provider => 'etcd',
}
```

Next, find somewhere to notify it. Let's imagine that your load balancers
also use puppetdbquery to discover eligible web server nodes, so when we set
up a new vhost all we have to do is tell the loadbalancers to run Puppet again:
```puppet
apache::vhost { 'first.example.com':
  port    => '80',
  docroot => '/var/www/first',
  notify  => Trigger['refresh load balancers'],
}
```

Note: this is all pretty speculative at this point. This isn't in use anywhere.
Don't try and use this unless you want to help build it.

## Limitations

There is no locking mechanism included, nor anything to prevent notify loops.
Sooner or later I'll add a TTL mechanism to trigger for the loops, and I'd love
to figure out how to deal with locks (e.g. which node is the db master / slave)
in a Puppet-native way.

## Development

If you want to help, writing more providers would be really great. Ping me
on IRC (@danieldreier) to coordinate.
