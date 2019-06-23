class WebCounterServer
  class HttpHeaders
    include Enumerable

    def initialize(headers = {})
      @headers = headers.transform_keys { |key| key.to_s.upcase }
    end

    def []=(key, value)
      @headers[key.to_s.upcase] = value
    end

    def [](key)
      @headers[key.to_s.upcase]
    end

    def each(*args, &block)
      @headers.each(*args, &block)
    end
  end
end
