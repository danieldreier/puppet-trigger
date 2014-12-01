require 'spec_helper'

describe 'trigger' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "trigger class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('trigger::params') }
        it { should contain_class('trigger::install').that_comes_before('trigger::config') }
        it { should contain_class('trigger::config') }
        it { should contain_class('trigger::service').that_subscribes_to('trigger::config') }

        it { should contain_service('trigger') }
        it { should contain_package('trigger').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'trigger class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('trigger') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
