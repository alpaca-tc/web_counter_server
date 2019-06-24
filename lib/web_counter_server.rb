require 'pry'
require 'logger'

class WebCounterServer
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

    response = @application.call
    socket.write(response)
  rescue
    logger.error 'failed'
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
