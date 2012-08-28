require 'spec_helper'

describe Braai::Template do
  
  let(:greet_regex) { /^greet$/i }
  let(:greet_handler) do
    ->(view, key, matches) {
      view.attributes[:greet]
    }
  end

  describe '.map' do

    it "let's you register a handler" do
      Braai::Template.handlers.should_not have_key(greet_regex.to_s)
      Braai::Template.map(greet_regex, &greet_handler)
      Braai::Template.handlers.should have_key(greet_regex.to_s)
    end
    
  end

  describe '#render' do

    before(:each) do
      Braai::Template.map(greet_regex, &greet_handler)
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
          <h2>{{greet.upcase}}</h2>
        EOF
      end

      it "renders the loop" do
        pending
        res = Braai::Template.new(template).render(greet: "mark", products: %w{car boat truck})
        res.should match("<h1>mark</h1>")
        res.should match("<li>car</li>")
        res.should match("<li>boat</li>")
        res.should match("<li>truck</li>")
        res.should match("<h2>MARK</h2>")
      end

    end

    context "default handler" do
      
      let(:template) { "{{ greet }} {{ name.upcase }}" }

      it "uses the default handler to render" do
        res = Braai::Template.new(template).render(greet: "Hi", name: "mark")
        res.should eql("Hi MARK")
      end

      it "handles the attribute not being there" do
        res = Braai::Template.new(template).render(greet: "Hi")
        res.should eql("Hi {{ name.upcase }}")
      end

    end

    context "missing handlers" do

      before(:each) do
        Braai::Template.reset!
      end

      after(:each) do
        Braai.config.raise_on_missing_handler = false
      end
      
      context "raise_on_missing_handler is true" do
        
        before(:each) do
          Braai.config.raise_on_missing_handler = true
        end

        it "raises an error" do
          expect {
            Braai::Template.new("{{ please.greet.me }}").render(greet: "Hi Mark")
          }.to raise_error(Braai::MissingHandlerError)
        end

      end

      context "raise_on_missing_handler is false" do

        it "does not raise an error" do
          expect {
            res = Braai::Template.new("{{ greet }}").render(greet: "Hi Mark")
            res.should eql("{{ greet }}")
          }.to_not raise_error(Braai::MissingHandlerError)
        end
        
      end

    end

    context "handler errors" do
      
      before(:each) do
        Braai::Template.map(/^foo$/) do |view, key, matches|
          raise ArgumentError 
        end
      end

      let(:template) { "{{ foo }}" }

      context "swallow_handler_errors is true" do
        
        it "swallows errors in the handler" do
          expect {
            res = Braai::Template.new(template).render()
            res.should eql template
          }.to_not raise_error
        end

      end

      context "swallow_handler_errors is false" do

        before(:each) do
          Braai.config.swallow_handler_errors = false
        end
        
        it "raises the errors from the handler" do
          expect {
            Braai::Template.new(template).render()
          }.to raise_error(ArgumentError)
        end

      end

    end

  end

end