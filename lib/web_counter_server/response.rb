class WebCounterServer
  class Response
    attr_accessor :status
    attr_reader :headers

    def initialize(request)
      @request = request
      @status = 200
      @headers = WebCounterServer::HttpHeaders.new
      @body = ''.dup
    end

    def set_status(status)
      @status = status
    end

    def set_body(body)
      @body = body
    end

    def build_response
      buffer = ''.dup
      buffer << "HTTP/#{@request.http_version} #{status}#{CRLF}"

      @headers.each do |name, value|
        buffer << "#{name}: #{value}#{CRLF}"
      end

      buffer << "Content-Length: #{@body.bytesize}#{CRLF}"
      buffer << CRLF

      buffer << @body
      buffer
    end
  end
end
