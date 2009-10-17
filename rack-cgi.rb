module Rack
  class Cgi
    F = ::File # Since there is a Rack::File

    attr_accessor :cgi_root
    attr_accessor :path

    def initialize(opts={})
      @cgi_root = opts[:cgi_root]
      @env = ENV.to_hash
    end

    def response(code,body)
      [code, {"Content-Type" => "text/plain",
              "Content-Length" => body.size.to_s},
              [body]]
    end

    def call(env)
      @path_info = Utils.unescape(env["PATH_INFO"])

      # Don't allow any tricks, I'm not sure if I should be doing
      # more (or less)
      if @path_info.include? ".." || @path_info.match(/\s/)
        return response(403,"Forbidden\n")
      end
      @path = F.join(@cgi_root, @path_info)

      begin 
        if F.file?(@path) && F.executable?(@path)
          run_cgi(env)
        else
          raise Errno::EPERM
        end
      rescue SystemCallError => e
        response(404, "File not found: #{@path_info}\n")
      end
    end

    def run_cgi(env)
      req = Rack::Request.new(env)

      header = {}
      body = []
      env.each do |k,v|
        ENV[k] = v if env[k].is_a? String
      end
      do_header = true
      data = open("| #{@path}") do |fd|
        fd.each_line do |l|
          if do_header
            if l =~ /^\s*$/
              do_header = false
            else
              m = l.match(/^(\S+):\s*(.*\S)\s*$/)
              header[m[1]] = m[2] if m
            end
          else
            body << l
          end
        end
      end
      env.each do |k,v|
        ENV[k].clear if env[k].is_a? String
      end
      [ 200, header, body]
    end

    private

  end
end
