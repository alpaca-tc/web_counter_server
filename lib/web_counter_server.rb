require 'pry'
require 'logger'

class WebCounterServer
  # String for linefeed
  MAX_URI_LENGTH = 2083 # URLの最長
  LF = "\012"
  CRLF = "\r\n"
  TERMINAL_RE = /(?:#{CRLF}|#{LF})/
  BLOCK_SIZE = 4096

  require 'web_counter_server/request'
  require 'web_counter_server/response'
  require 'web_counter_server/http_headers'

  def self.start(host: '127.0.0.1', port: '8080', &block)
    new(host: host, port: port, &block).start
  end

  def self.logger
    @logger ||= Logger.new($stdout)
  end

  def initialize(host:, port:, &block)
    @host = host
    @port = port
    @application = block
  end

  def start
    trap('INT') { on_exit }

    logger.debug("Listening on tcp://#{@host}:#{@port}")
    server = TCPServer.new(@host, @port)
    server.listen(5)

    run(server)
  end

  private

  def run(server)
    loop do
      socket = server.accept_nonblock
      serve(socket)
    rescue IO::WaitReadable, Errno::EINTR
      IO.select([server])
      retry
    end
  end

  def serve(socket)
    socket.to_io.wait_readable(0.5)
    raise 'Invalid sequence' if socket.eof?

    request = WebCounterServer::Request.parse(socket)
    response = WebCounterServer::Response.new(request)

    @application.call(request, response)

    socket.write(response.build_response)
  ensure
    socket.close
  end

  def logger
    self.class.logger
  end

  # https://bugs.ruby-lang.org/issues/7917
  def on_exit
    Thread.new {
      puts ""
      logger.debug('Goodbye!')
      exit
    }.join
  end
end
