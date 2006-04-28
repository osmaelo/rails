require 'optparse'

if RUBY_PLATFORM =~ /mswin32/ then abort("Reaper is only for Unix") end

OPTIONS = {
  :pid_path => File.expand_path(RAILS_ROOT + '/tmp/pids'),
  :pattern  => "dispatch.*.pid",
  :ps       => "ps -o user,start,etime,pcpu,vsz,majflt,command -p %s"
}

class Inspector
  def self.inspect(pid_path, pattern)
    new(pid_path, pattern).inspect
  end

  def initialize(pid_path, pattern)
    @pid_path, @pattern = pid_path, pattern
  end

  def inspect
    for process in find_processes
      puts "#{File.basename(process[:pid_file])}:"
      puts(`#{OPTIONS[:ps] % process[:pid]}`)
      puts
    end
  end

  private
    def find_processes
      pid_files.inject([]) do |pids, pid_file|
        pids << { :pid_file => pid_file, :pid => File.read(pid_file).to_i }
      end
    end

    def pid_files
      Dir.glob(@pid_path + "/" + @pattern)
    end
end


ARGV.options do |opts|
  opts.banner = "Usage: inspector [options]"

  opts.separator ""

  opts.on <<-EOF
  Description:
    Get the lowdown on processes.

  Examples:
    inspector
    inspector -s 'ps -o user,start,majflt,pcpu,vsz -p %s'
  EOF

  opts.on("  Options:")

  opts.on("-s", "--ps=command", "default: #{OPTIONS[:ps]}", String)           { |OPTIONS[:ps]| }
  opts.on("-p", "--pidpath=path", "default: #{OPTIONS[:pid_path]}", String)   { |OPTIONS[:pid_path]| }
  opts.on("-r", "--pattern=pattern", "default: #{OPTIONS[:pattern]}", String) { |OPTIONS[:pattern]| }

  opts.separator ""

  opts.on("-h", "--help", "Show this help message.") { puts opts; exit }

  opts.parse!
end

Inspector.inspect(OPTIONS[:pid_path], OPTIONS[:pattern])