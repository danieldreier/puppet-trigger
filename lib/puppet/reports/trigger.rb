require 'puppet'
require 'puppet/util'
require 'pp'
#require 'yaml'
# this is a report processor that looks for "trigger" resource refreshes and calls mcollective to run puppet on the nodes to be refreshed

Puppet::Reports.register_report(:trigger) do
  desc "Trigger puppet agent runs via mcollective when reports indicate that
        the a Trigger resource was refreshed during catalog application. This
        provides a basic quasi-orchestration facility.

        This implements a provider for the trigger resource; other providers
        are also possible to avoid the need for a puppet master.

        Note that this report processor does not actually generate reports."

  def process
    self.resource_statuses.each do | name, status |
      status_hash = status.to_data_hash
      status_hash[:environment] = self.environment
      if status_hash['resource_type'] == "Trigger"
        puts pp(status_hash)
      end

      # stuff we're looking for
      # resource_type => Trigger in status_hash
      # "changed"=>true
      # "events"=>[defined 'message' as 'hello, world']
      # "title"=>"hello, world"
    end
  end
end
