require 'spec_helper'

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

    it "let's you register a matcher" do
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
          Braai::Template.map(multi_regex, &multi_matcher)
        end

        it "allows nil matches" do
          template = "<h1>{{ greet }}</h1><h2>{{ greet mark }}</h2>"
          res = Braai::Template.new(template).render
          res.must_equal("<h1>greet</h1><h2>greetmark</h2>")
        end

      end

    end

    describe "for loops" do

      let(:template) do
<<-EOF
<h1>{{ greet }}</h1>
<ul>
  {{ for product in products }}
    <li>{{ product }}</li>
  {{ /for }}
</ul>
<div>
  {{ for food in foods }}
    <p>{{ food }}</p>
  {{ /for }}
</div>
<h2>{{greet.upcase}}</h2>
EOF
      end

      it "renders the loop" do
        res = Braai::Template.new(template).render(greet: "mark", products: %w{car boat truck}, foods: %w{apple orange})
        res.must_match("<h1>mark</h1>")
        res.must_match("<li>car</li>")
        res.must_match("<li>boat</li>")
        res.must_match("<li>truck</li>")
        res.must_match("<p>apple</p>")
        res.must_match("<p>orange</p>")
        res.must_match("<h2>MARK</h2>")
      end

    end

    describe "default matcher" do

      let(:template) { "{{ greet }} {{ name.upcase }}" }

      it "uses the default matcher to render" do
        res = Braai::Template.new(template).render(greet: "Hi", name: "mark")
        res.must_equal("Hi MARK")
      end

      it "handles the attribute not being there" do
        res = Braai::Template.new(template).render(greet: "Hi")
        res.must_equal("Hi {{ name.upcase }}")
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