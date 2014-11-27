require 'puppet/parameter/boolean'

Puppet::Type.newtype(:trigger) do
  @doc = %q{Ctype to trigger puppet agent runs on remote nodes. Depending on
    on the provider, this can occur through a variety of backends or using
    mcollective via the report processor. A puppet master is required.

    The Trigger type does nothing when declared, and must be started via a
    refresh to actually trigger the remote agent run.

    Example:
    This example demonstrates use of trigger with an haproxy load balancer
    member. The load balancers will run puppet and collect the exported
    resource after the report processor runs.

        trigger {'refresh load balancers':
          hosts    => ['lb01.example.com', 'lb02.example.com'],
          provider => 'mcollective',
        }

        haproxy::balancermember { 'haproxy':
          listening_service => 'webserver',
          ports             => '80',
          server_names      => $::hostname,
          ipaddresses       => $::ipaddress,
          options           => 'check',
          notify            => Trigger['refresh load balancers'],
        }
  }
  feature :refreshable, "The provider can restart the service.",
      :methods => [:restart]

  def refresh
    provider.restart
  end

  newparam(:name, namevar: true) do
    desc 'the name of the trigger group'
    validate do |value|
      fail Puppet::Error, 'Empty values are not allowed' if value == ''
    end
  end

  newparam(:hosts, :array_matching => :all) do
    defaultto []
    desc 'the hosts to trigger puppet agent runs on'
  end

  newparam(:ttl) do
    desc 'the time-to-live to prevent trigger loops.'
    validate do |value|
      fail Puppet::Error, 'must be an integer' unless value.is_a?(Integer)
    end
  end

  newparam(:keyprefix) do
    desc 'prefix to use with key-value store providers'
    defaultto '/puppet_trigger/events'
    validate do |value|
      fail Puppet::Error, 'must be an string' unless value.is_a?(String)
    end
  end

  newparam(:keyttl) do
    desc 'TTL to use with key-value store providers that support ttl'
    defaultto 180
    validate do |value|
      fail Puppet::Error, 'must be an integer' unless value.is_a?(Integer)
    end
  end

  # may want to add ability to contain to current environment or use tags
end
