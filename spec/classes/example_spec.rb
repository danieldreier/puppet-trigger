require 'spec_helper'

describe 'trigger' do
  context 'supported operating systems' do
#    PuppetSpecFacts.puppet_platforms.each do |name, facthash|
    PuppetSpecFacts.facts_for_platform_by_fact(select_facts: {'lsbdistid' => 'CentOS',
                                                              'is_pe'       => 'true',
                                                              'architecture' => 'x86_64' }).each do |name, facthash|
      describe "trigger class without any parameters on #{name}" do
        let(:params) {{ }}
        let(:facts) { facthash }

        it { should compile.with_all_deps }
      end
    end
  end
end
