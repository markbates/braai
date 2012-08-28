require 'spec_helper'

describe Braai::Handlers do
  include Braai::Handlers
  
  describe 'map' do

    it "maps a new handler" do
      map("foo") {}
      handlers.should include("foo")
    end

    it "makes the latest handler the first handler in the list" do
      map("foo") {}
      map("bar") {}
      handlers.keys.first.should eql("bar")
    end
    
  end

  describe 'unmap' do
    
    it "unmaps a handler" do
      map("foo") {}
      handlers.should include("foo")
      unmap("foo")
      handlers.should_not include("foo")
    end

  end

  describe 'clear!' do
    
    it "removes all of the handlers" do
      map("foo") {}
      handlers.should_not be_empty
      clear!
      handlers.should be_empty
    end

  end

  describe 'reset!' do
    
    it "resets the handlers to their original state" do
      handlers.should have(2).handlers
      map("foo") {}
      handlers.should have(3).handlers
      reset!
      handlers.should have(2).handlers
    end

  end

end