require 'spec_helper'
require 'ostruct'

describe Braai::Template do


  class GreetHandler
    def self.call(template, key, matches)
      template.attributes[:greet].upcase
    end
  end

  let(:greet_regex) { /^greet$/i }
  let(:greet_matcher) do
    ->(view, key, matches) {
      view.attributes[:greet]
    }
  end

  describe '.map' do

    it "lets you register a matcher" do
      Braai::Template.matchers.wont_include(greet_regex.to_s)
      Braai::Template.map(greet_regex, &greet_matcher)
      Braai::Template.matchers.must_include(greet_regex.to_s)
    end

    it "takes a class that responds to call" do
      Braai::Template.map(greet_regex, GreetHandler)
      Braai::Template.matchers.must_include(greet_regex.to_s)
    end

  end

  describe '#render' do

    before do
      Braai::Template.map(greet_regex, &greet_matcher)
      Braai::Template.map(/{{ greetings }}/i, GreetHandler)
    end

    it "renders a template without matches" do
      res = Braai::Template.new("Hi {{ greet }}").render()
      res.must_equal("Hi {{ greet }}")
    end

    it "renders a simple template using a block" do
      res = Braai::Template.new("{{ greet }}").render(greet: "Hi Mark")
      res.must_equal("Hi Mark")
    end

    it "renders a simple template using a handler class" do
      res = Braai::Template.new("{{ greetings }}").render(greet: "Hi Mark")
      res.must_equal("HI MARK")
    end

    it "doesn't care about spaces" do
      template = "<h1>{{greet}}</h1><h2>{{ greet }}</h2>"
      res = Braai::Template.new(template).render(greet: "Hi Mark")
      res.must_equal("<h1>Hi Mark</h1><h2>Hi Mark</h2>")
    end


    describe 'matches' do

      describe 'multimatches' do

        let(:multi_regex) { /({{\s*(greet)\s*(mark)?\s*}})/ }
        let(:multi_matcher) do
          ->(view, key, matches) {
            "#{matches[1]}#{matches[2]}"
          }
        end

        before do
          Braai::Template.clear!
          Braai::Template.map(multi_regex, &multi_matcher)
        end

        it "allows nil matches" do
          template = "<h1>{{ greet }}</h1><h2>{{ greet mark }}</h2>"
          res = Braai::Template.new(template).render
          res.must_equal("<h1>greet</h1><h2>greetmark</h2>")
        end

        it "matches only one" do
          template = "<h1>{{ greet }}</h1><h2>{{ unmatched }}</h2>"
          res = Braai::Template.new(template).render
          res.must_equal("<h1>greet</h1><h2>{{ unmatched }}</h2>")
        end

      end

    end


    describe "fallback matcher" do

      before do
        Braai::Template.map(/({{ yummy_(\w+) }})/, ->(view, key, matches) { "#{matches[1].upcase}: #{view.attributes[matches[1]]}" })
        Braai::Template.add_fallback(/({{ (\w+) }})/, ->(view, key, matches) { "UNMATCHED_TAG" })
      end

      it "is called" do
        template = "<h2>{{ bango }}</h2>"
        res = Braai::Template.new(template).render
        res.must_equal("<h2>UNMATCHED_TAG</h2>")
      end

      it "always comes last" do
        template = "<h2>{{ bango }}</h2><p>{{ yummy_food }}</p><p>{{ yummy_drink }}</p> {{ blaz }}"

        res = Braai::Template.new(template).render(food: 'pizza', drink: 'beer')
        res.must_equal("<h2>UNMATCHED_TAG</h2><p>FOOD: pizza</p><p>DRINK: beer</p> UNMATCHED_TAG")
      end

    end

    describe "matcher errors" do

      before do
        Braai::Template.map(/foo/) do |view, key, matches|
          raise ArgumentError
        end
      end

      let(:template) { "foo" }

      describe "swallow_matcher_errors is true" do

        before do
          Braai.config.swallow_matcher_errors = true
        end

        it "swallows errors in the matcher" do
          -> {
            res = Braai::Template.new(template).render()
          }
        end

      end

      describe "swallow_matcher_errors is false" do

        before do
          Braai.config.swallow_matcher_errors = false
        end

        it "raises the errors from the matcher" do
          -> {
            res = Braai::Template.new(template).render
          }.must_raise(ArgumentError)
        end

      end

    end

  end

end
