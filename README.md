# Simple HTTP Router

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     http-router:
       github: willhbr/http-router
   ```

2. Run `shards install`

## Usage

```crystal
require "http/server"
require "http-router"

class MyHander
  include HTTP::Handler
  include HTTP::Router

  @[HTTP::Route(path: "/stuff")]
  @[HTTP::Route(path: "/stuff", method: :HEAD)]
  def get_stuff(context)
    context.ok_json(result: "success!")
  end

  @[HTTP::Route(path: "/stuff", method: :POST)]
  def post_stuff(context)
    contents = context.request.body.get_to_end
    puts contents
    context.ok_json(result: "success!")
  end
end
```

This will generate a `call(context)` method like this:

```crystal
def call(context : HTTP::Server::Context)
  req = context.request
  case { req.method, req.path }
  when { "GET", "/stuff" }
    self.get_stuff(context)
  when { "HEAD", "/stuff" }
    self.get_stuff(context)
  when { "POST", "/stuff" }
    self.post_stuff(context)
  else
    call_next context
  end
end
```

`http-router` doesn't support any destructuring of the path. Maybe you could send a PR for that.

## Contributing

1. Fork it (<https://github.com/willhbr/http-router/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Will Richardson](https://github.com/willhbr) - creator and maintainer
