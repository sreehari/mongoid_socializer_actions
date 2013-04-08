require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Socializer::Configuration do
  describe '#configure' do
    it 'should have default attributes' do
      Socializer.configure do |configuration|
        configuration.user_class_name.should eql('User')
      end
    end

    it 'should have default attributes' do
      Socializer.user_class_name.should eql('User')
    end

    it 'should accept user settings' do
      Socializer.configure do |configuration|
        configuration.user_class_name = 'Customer'
      end

      Socializer.user_class_name.should eql('Customer')
    end
  end
end