require "http/server"

annotation HTTP::Route
end

class HTTP::Server::Context
  # Respond 200 with a JSON body
  def ok_json(full_object)
    self.response.content_type = "application/json"
    self.response.status = HTTP::Status::OK
    full_object.to_json(self.response)
  end

  # Respond 200 with a JSON body from keyword arguments
  def ok_json(**args)
    self.response.content_type = "application/json"
    args.to_json(self.response)
  end

  # Respond 200 with text
  def ok_text(resp)
    self.response.content_type = "text/plain"
    resp.to_s(self.response)
  end

  # Respond 404 with message
  def not_found(message : String? = nil)
    fail(HTTP::Status::NOT_FOUND, message)
  end

  # Respond a status with a message
  def fail(status : HTTP::Status, message : String? = nil)
    self.response.status = status
    self.response.content_type = "text/plain"
    if msg = message
      self.response.puts msg
    else
      self.response.puts status
    end
  end

  # Get a query parameter
  def query_string(name) : String
    self.request.query_params[name]
  end

  # Get a query parameter as a number
  def query_number(name) : Int32
    self.request.query_params[name].to_i
  end
end

module HTTP::Router
  macro included
    macro finished
      generate_routing
    end
  end

  macro generate_routing
    def call(context : HTTP::Server::Context)
      {% begin %}
        %req = context.request
        {% used = {} of String => Nil %}
        case { %req.method, %req.path }
          {% for method in @type.methods %}
            {% for ann in method.annotations ::HTTP::Route %}
              {%
                http_method = ann[:method] || :GET
                path = ann[:path] || raise "Missing path on @[HTTP::Route]"
              %}
              {% if ex = used[http_method + path]
                   raise "Duplicate @[HTTP::Route] #{http_method.id} #{path}: #{ex.name}, #{method.name}"
                 end %}
              {% used[http_method + path] = method %}
              when { {{ http_method.id.stringify }}, {{ path }} }
                self.{{ method.name }}(context)
            {% end %}
          {% end %}
        else
          call_next context
        end
      {% end %}
    end
  end
end
