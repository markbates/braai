require 'spec_helper'

describe 'README' do

  it "simple example" do
    template = "Hi {{ name }}!"
    response = Braai::Template.new(template).render(name: "Mark")
    response.should eql "Hi Mark!"
  end  

  it "simple method call example" do
    template = "Hi {{ name.upcase }}!"
    response = Braai::Template.new(template).render(name: "Mark")
    response.should eql "Hi MARK!"
  end

  it "custom matcher example" do
    template = "I'm {{ name }} and {{ mmm... bbq }}!"
    Braai::Template.map(/({{\s*mmm\.\.\. bbq\s*}})/i) do |template, key, matches|
      "Damn, I love BBQ!"
    end

    Braai::Template.map(/({{\s*name\s*}})/i) do |template, key, matches|
      template.attributes[:name].upcase
    end

    response = Braai::Template.new(template).render(name: "mark")
    response.should eql "I'm MARK and Damn, I love BBQ!!"
  end

  it "for loop example" do
    template = <<-EOF
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

  res = Braai::Template.new(template).render(greet: "mark", products: %w{car boat truck}, foods: %w{apple orange})
  res.should match("<h1>mark</h1>")
  res.should match("<li>car</li>")
  res.should match("<li>boat</li>")
  res.should match("<li>truck</li>")
  res.should match("<p>apple</p>")
  res.should match("<p>orange</p>")
  res.should match("<h2>MARK</h2>")
  end

        # it "description" do
      #   template = "I'm {{ name }} and {{ mmm... bbq }}!"
      #   Braai::Template.map(/mmm\.\.\. bbq/i) do |template, key, matches|
      #     puts "key: #{key.inspect}"
      #     puts "matches: #{matches.inspect}"
      #     "Damn, I love BBQ!"
      #   end

      #   Braai::Template.map(/name/i) do |template, key, matches|
      #     template.attributes[matches.first].upcase
      #   end

      #   puts Braai::Template.new(template).render(name: "Mark")
      # end

end