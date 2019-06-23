require 'etc'

class WebCounterServer
  class Usage
    attr_reader :maximum_cpu_usage, :maximum_memory_usage

    def initialize(pid = Process.pid)
      @pid = pid
    end

    def build_usage
      cpu_bar = "\e[1mCPU Usage:\e[0m #{bar(cpu_used, maximum_cpu_usage, console_width, '%')}"
      memory_bar = "\e[1mMEM Usage:\e[0m #{bar(memory_used, memory_size, console_width, 'MB')}"

      "#{cpu_bar} -- #{memory_bar}"
    end

    private

    def bar(used, maximum, width, unit)
      usage = (used / maximum)
      usage_width = width * usage
      not_usage_width = width - usage_width

      bar_line = "[\e[32m#{'=' * usage_width}\e[0m#{' ' * not_usage_width}]"
      "#{used.round(1).to_s.rjust(7)}#{unit} / #{maximum.round(1)}#{unit} #{bar_line}"
    end

    def console_width
      20
    end

    def maximum_cpu_usage
      cpu_count * 100.0
    end

    def cpu_count
      Etc.nprocessors
    end

    def memory_size
      @memory_size ||= extract_tail_integer(`sysctl hw.memsize`) / 1_000_000
    end

    def cpu_used
      extract_tail_integer(`ps -p #{@pid} -o %cpu`)
    end

    def memory_used
      extract_tail_integer(`ps -p #{@pid} -o rss`) / 1_000
    end

    def extract_tail_integer(text)
      text.strip.match(/[\d\.]+$/)[0].to_f
    end
  end
end
