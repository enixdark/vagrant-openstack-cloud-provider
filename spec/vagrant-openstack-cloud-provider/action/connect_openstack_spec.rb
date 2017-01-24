require 'spec_helper'
require 'vagrant-openstack-cloud-provider/errors'
require 'vagrant-openstack-cloud-provider/action/connect_openstack'
require "fog"

RSpec.describe VagrantPlugins::OpenStack::Action::ConnectOpenStack do
  describe '#call?' do
    let (:app) { double }
    let (:machine) { double }
    let (:config) { double(
        :config,
        :region    => nil,
        :username  => 'username',
        :api_key   => 'password',
        :endpoint  => 'http://openstack.invalid/',
        :tenant    => nil,
      )
    }

    subject {
      described_class.new(app, nil)
    }

    it "should new members in env" do
      expect(app).to receive(:call)
      expect(machine).to receive(:provider_config).and_return(config)
      env = { :machine => machine }

      subject.call(env)

      expect(env).to have_key(:openstack_compute)
      expect(env).to have_key(:openstack_network)
    end

    {Fog::Compute => :openstack_compute,
     Fog::Network => :openstack_network}.each do |klass, attribute|
      it "should late-evaluate #{klass}" do
        expect(app).to receive(:call)
        expect(machine).to receive(:provider_config).and_return(config)
        env = { :machine => machine }

        expect(klass).to receive(:new).and_raise(MyError)

        subject.call(env)

        expect { env[attribute].any_call }.to raise_error(MyError)
      end
    end

  end
end

class MyError < StandardError

end
