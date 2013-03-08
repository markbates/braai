# Braai

A fully extensible templating system. Sick and tired of all of those templating systems that force you to do things their way? Yeah, me too! Thankfully there's Braai. 
Braai let's you write your own Regular Expression matchers and then do whatever you'd like when the template is parsed! Sounds fun, doesn't it?

## Installation

Add this line to your application's Gemfile:

    gem 'braai'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install braai

## Usage

### Built-in Matchers

Braai comes shipped with two simple matchers for you, but you can easily add your own.

The first matcher is a simple <code>to_s</code> matcher. It will match a single variable and then call <code>to_s</code> on it:

```ruby
template = "Hi {{ name }}!"
response = Braai::Template.new(template).render(name: "Mark")
response.must_equal "Hi Mark!"
```

The second matcher will call a method on the variable.

```ruby
template = "Hi {{ name.upcase }}!"
response = Braai::Template.new(template).render(name: "Mark")
response.must_equal "Hi MARK!"
```

### Custom Matchers

Braai let's you easily define your own matchers to do whatever you would like to do.

```ruby
template = "I'm {{ name }} and {{ mmm... bbq }}!"
Braai::Template.map(/({{\s*mmm\.\.\. bbq\s*}})/i) do |template, key, matches|
  "Damn, I love BBQ!"
end

Braai::Template.map(/({{\s*name\s*}})/i) do |template, key, matches|
  template.attributes[:name].upcase
end

response = Braai::Template.new(template).render(name: "mark")
response.must_equal "I'm MARK and Damn, I love BBQ!!"
```

### For Loops

Braai supports looping right out of the box.

```ruby
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
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributers

* Mark Bates
* Nick Plante
* Sam Beam
* Kevin Incorvia