require 'spec_helper.rb'

describe Braai::Context do

  describe '#initialize' do

    it 'allows a hash as the value in an attributes key/value pair' do
      hash = { foo: 'bar' }
      context = Braai::Context.new("template", "matchers", { hash: hash })
      context.attributes[:hash].should eql("foo" => 'bar')
    end
  end
end
