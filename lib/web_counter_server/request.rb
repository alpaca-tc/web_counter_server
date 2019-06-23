class WebCounterServer
  class Request
    HEAD_RE = /^(?<http_method>\S+)\s+(?<uri>\S++)(?:\s+HTTP\/(?<http_version>\d+\.\d+))?\r?\n/mo
    TERMINAL_HEADER = /\A(?:#{CRLF}|#{LF})\z/

    class << self
      def parse(socket)
        head_line = socket.gets(LF, MAX_URI_LENGTH) # GET / HTTP/1.1\r\n

        # parse http_method, uri, http_version

        headers = WebCounterServer::HttpHeaders.new

        while raw_header = socket.gets(LF, BLOCK_SIZE) # g.u "Host: 127.0.0.1:8080\r\n"
          break if TERMINAL_HEADER.match?(raw_header)
          name, value = parse_header(raw_header)
          headers[name] = value
        end

        head = HEAD_RE.match(head_line)

        new(
          http_version: head[:http_version],
          uri: head[:uri],
          http_method: head[:http_method],
          headers: headers
        )
      end

      private

      def parse_header(raw_header)
        delimiter_index = raw_header.index(':')
        name = raw_header[0..delimiter_index - 1]
        value = raw_header[delimiter_index + 2..-1].chomp

        [name, value]
      end
    end

    attr_reader :headers, :body, :http_method, :uri, :http_version

    def initialize(http_version:, uri:, http_method:, headers:)
      @http_version = http_version
      @uri = uri
      @http_version = http_version
      @headers = headers
      @body = body
    end
  end
end
