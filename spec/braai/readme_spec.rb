require 'spec_helper'

describe 'README' do

  it "simple example" do
    template = "Hi {{ name }}!"
    response = Braai::Template.new(template).render(name: "Mark")
    response.must_equal "Hi Mark!"
  end  

  it "simple method call example" do
    template = "Hi {{ name.upcase }}!"
    response = Braai::Template.new(template).render(name: "Mark")
    response.must_equal "Hi MARK!"
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
    response.must_equal "I'm MARK and Damn, I love BBQ!!"
  end

  it "if statement example" do
    template = '{{ product.name }}{{ if product.featured }}***{{ /if }}'
    featured_product = OpenStruct.new(name: 'Special Product', featured: true)
    regular_product = OpenStruct.new(name: 'Regular Product', featured: false)
    Braai::Template.new(template).render(product: featured_product).must_equal("Special Product***")
    Braai::Template.new(template).render(product: regular_product).must_equal("Regular Product")
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
    res.must_match("<h1>mark</h1>")
    res.must_match("<li>car</li>")
    res.must_match("<li>boat</li>")
    res.must_match("<li>truck</li>")
    res.must_match("<p>apple</p>")
    res.must_match("<p>orange</p>")
    res.must_match("<h2>MARK</h2>")
  end

end
