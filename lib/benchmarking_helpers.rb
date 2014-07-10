module BenchmarkingHelpers
  def measure(description, &block)
    return_value = nil
    elapsed_time = Benchmark.realtime { return_value = block.call }
    puts "Time to #{description}: #{elapsed_time} seconds"
    return_value
  end

  def profile(name, &block)
    if OptimalRecipeGenerator.profile
      return_value = nil
      error = nil
      result = RubyProf.profile do
        begin
          return_value = block.call
        rescue => error
          puts error
        end
      end
      raise error if error
      printer = RubyProf::GraphHtmlPrinter.new(result)
      printer.print(File.open("profiles/#{name}.html", 'w'))
      return_value
    else
      block.call
    end
  end
end
