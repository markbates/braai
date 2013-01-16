require 'spec_helper'

describe Braai::Matchers do
  include Braai::Matchers
  
  describe 'map' do

    it "maps a new matcher" do
      map("foo") {}
      matchers.must_include("foo")
    end

    it "makes the latest matcher the first matcher in the list" do
      map("foo") {}
      map("bar") {}
      matchers.keys.first.must_equal("bar")
    end
    
  end

  describe 'unmap' do
    
    it "unmaps a matcher" do
      map("foo") {}
      matchers.must_include("foo")
      unmap("foo")
      matchers.wont_include("foo")
    end

  end

  describe 'clear!' do
    
    it "removes all of the matchers" do
      map("foo") {}
      matchers.wont_be_empty
      clear!
      matchers.must_be_empty
    end

  end

  describe 'reset!' do

    it "resets the matchers to their original state" do
      matchers.size.must_equal(3)
      map("foo") {}
      matchers.size.must_equal(4)
      reset!
      matchers.size.must_equal(3)
    end

  end

  describe 'set_defaults' do

    it "installs the three base matchers" do
      clear!
      map("foo") {}
      matchers.size.must_equal(1)
      set_defaults
      matchers.size.must_equal(4)
    end

  end

end
