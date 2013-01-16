require 'spec_helper.rb'

describe Braai::Context do

  describe '#initialize' do

    describe 'attributes arguments' do

      it 'allows a nested hash' do
        context = Braai::Context.new("template", "matchers", { hash: { foo: 'bar' } })
        context.attributes[:hash].must_equal("foo" => 'bar')
      end

    end

  end

end