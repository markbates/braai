require 'spec_helper'

describe Braai::Template do
  
  let(:greet_regex) { /^greet$/i }
  let(:greet_matcher) do
    ->(view, key, matches) {
      view.attributes[:greet]
    }
  end

  describe '.map' do

    it "let's you register a matcher" do
      Braai::Template.matchers.should_not have_key(greet_regex.to_s)
      Braai::Template.map(greet_regex, &greet_matcher)
      Braai::Template.matchers.should have_key(greet_regex.to_s)
    end
    
  end

  describe '#render' do

    before(:each) do
      Braai::Template.map(greet_regex, &greet_matcher)
    end
    
    it "renders a simple template" do
      res = Braai::Template.new("{{ greet }}").render(greet: "Hi Mark")
      res.should eql("Hi Mark")
    end

    it "doesn't care about spaces" do
      template = "<h1>{{greet}}</h1><h2>{{ greet }}</h2>"
      res = Braai::Template.new(template).render(greet: "Hi Mark")
      res.should eql("<h1>Hi Mark</h1><h2>Hi Mark</h2>")
    end

    context "for loops" do
      
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
        res.should match("<h1>mark</h1>")
        res.should match("<li>car</li>")
        res.should match("<li>boat</li>")
        res.should match("<li>truck</li>")
        res.should match("<p>apple</p>")
        res.should match("<p>orange</p>")
        res.should match("<h2>MARK</h2>")
      end

    end

    context "default matcher" do
      
      let(:template) { "{{ greet }} {{ name.upcase }}" }

      it "uses the default matcher to render" do
        res = Braai::Template.new(template).render(greet: "Hi", name: "mark")
        res.should eql("Hi MARK")
      end

      it "handles the attribute not being there" do
        res = Braai::Template.new(template).render(greet: "Hi")
        res.should eql("Hi {{ name.upcase }}")
      end

    end

    context "matcher errors" do
      
      before(:each) do
        Braai::Template.map(/foo/) do |view, key, matches|
          raise ArgumentError 
        end
      end

      let(:template) { "foo" }

      context "swallow_matcher_errors is true" do
        
        it "swallows errors in the matcher" do
          expect {
            res = Braai::Template.new(template).render()
          }.to_not raise_error
        end

      end

      context "swallow_matcher_errors is false" do

        before(:each) do
          Braai.config.swallow_matcher_errors = false
        end
        
        it "raises the errors from the matcher" do
          expect {
            res = Braai::Template.new(template).render
          }.to raise_error(ArgumentError)
        end

      end

    end

  end

end