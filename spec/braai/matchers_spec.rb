require 'spec_helper'

describe Braai::Matchers do
  include Braai::Matchers
  
  describe 'map' do

    it "maps a new matcher" do
      map("foo") {}
      matchers.should include("foo")
    end

    it "makes the latest matcher the first matcher in the list" do
      map("foo") {}
      map("bar") {}
      matchers.keys.first.should eql("bar")
    end
    
  end

  describe 'unmap' do
    
    it "unmaps a matcher" do
      map("foo") {}
      matchers.should include("foo")
      unmap("foo")
      matchers.should_not include("foo")
    end

  end

  describe 'clear!' do
    
    it "removes all of the matchers" do
      map("foo") {}
      matchers.should_not be_empty
      clear!
      matchers.should be_empty
    end

  end

  describe 'reset!' do
    
    it "resets the matchers to their original state" do
      matchers.should have(2).matchers
      map("foo") {}
      matchers.should have(3).matchers
      reset!
      matchers.should have(2).matchers
    end

  end

end