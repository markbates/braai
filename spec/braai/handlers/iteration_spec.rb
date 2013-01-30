require 'spec_helper'

describe Braai::Handlers::Iteration do
  include Mocha::Integration::MiniTest
  include Braai::Matchers

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
