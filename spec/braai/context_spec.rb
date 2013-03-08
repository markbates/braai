require 'spec_helper.rb'

describe Braai::Context do

  describe '#initialize' do

    describe 'attributes arguments' do

      it 'allows a nested hash' do
        template = mock(:matchers => true, :fallback => true)
        context = Braai::Context.new("some {{stuff}}", template, { hash: { foo: 'bar' } })
        context.attributes[:hash].must_equal("foo" => 'bar')
      end

    end

  end

end
