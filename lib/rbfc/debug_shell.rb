require 'rbfc/virtual_machine'

module RBFC

  class DebugShell

    attr_accessor :runtime

    def initialize compiled_code, source_code, input, console

      @compiled_code = compiled_code
      @compiled_code.source = source_code

      @input = input
      @console = console

      @breakpoints = []
      @break_condition = nil

      @running = @stepping = false

    end

    def [] instruction_index

      instruction = @compiled_code[instruction_index]

      @stepping = true if break_run?(instruction_index)

      return instruction if instruction.nil? || instruction.is_a?(Integer)

      if @stepping

        display_current instruction_index

        loop do

          cmd = input_command

          x = execute(cmd)

          break if x == :continue

        end

      end

      instruction

    end

    def start

      @console.puts "Brainfuck debugger #{VERSION}"
      @console.puts "Type 'exit' to exit the debugger"
      @console.puts "     'help' to display all commands"

      catch(:exit_shell) do

        loop do

          cmd = input_command

          catch(:stop_program) {execute(cmd)}

        end

      end

    end

    def input_command

      state = @running ? "*" : ""

      @console.print "db#{state}> "
      cmd = $stdin.gets

      cmd = "exit" if cmd.nil?

      cmd.strip.downcase

    end

    def execute cmd

      return :continue if cmd == ""

      cmd =~ /(\w+)(.*)/

      cmd = $1
      args = $2.split

      cmd_method = "#{cmd}_command".to_sym

      if self.respond_to?(cmd_method)

        n = self.method(cmd_method).arity

        if n >= 0 && n != args.size
          @console.puts "Invalid arguments for '#{cmd}'"
        else

          begin
            self.send(cmd_method, *args)
          rescue ArgumentError
            @console.puts "Invalid arguments for '#{cmd}'"
          end

        end

      else
        @console.puts "Unknown command"
      end

    end

    def exit_command
      throw :exit_shell
    end

    def help_command

      max_name = 0

      commands = []

      self.methods.each do |method|

        if method =~ /(.*)_command_help$/

          name = $1

          help = self.send(method)

          if help.respond_to?(:each)

            help.each do |info|

              name = info[:alias] if info[:alias]

              real_name = "#{name} #{info[:args]}"

              max_name = [max_name, real_name.size].max

              commands << [real_name, info[:desc]]

            end

          else

            max_name = [max_name, name.size].max

            commands << [name, help]

          end

        end

      end

      max_name += 5

      commands.sort! {|item_a, item_b| item_a[0] <=> item_b[0]}

      commands.each do |name, help|
        @console.print "  "
        @console.print name.ljust(max_name)
        @console.puts help
      end

    end

    def step_command

      return :continue if @stepping

      @stepping = true

      run_command unless @running

    end

    def stop_command

      @runtime = nil
      @running = false
      @stepping = false

      throw :stop_program

    end

    def run_command

      if @running
        @stepping = false
        return :continue
      end

      @running = true

      @input.rewind unless @input == $stdin

      VirtualMachine.new(self, @input).run(self)

      stop_command

    end

    def b_command n

      raise ArgumentError unless n =~ /^\d+$/

      n = n.to_i

      raise ArgumentError if n == 0

      if n > @compiled_code.number_of_lines
        @console.puts "Source file has only #{@compiled_code.number_of_lines} line(s)"
      else
        @breakpoints << n
        @breakpoints.sort!
      end

    end

    def be_command n

      raise ArgumentError unless n =~ /^\d+$/

      n = n.to_i

      @break_condition = n

    end

    def list_command

      @breakpoints.each do |line|
        @console.puts "%3d: #{@compiled_code.line(line - 1)}" % line
      end

      if @break_condition
        puts unless @breakpoints.empty?
        puts "  stop when current cell equals #{@break_condition}" if @break_condition
      end

    end

    def clear_command n

      if n == 'all'
        @breakpoints.clear
        @break_condition = nil
      elsif n == 'c'
        @break_condition = nil
      else

        raise ArgumentError unless n =~ /^\d+$/

        n = n.to_i

        @breakpoints.delete_at n - 1

      end

    end

    def dump_command i = nil, n = nil

      raise ArgumentError unless i.nil? or i =~ /^\d+$/
      raise ArgumentError unless n.nil? or n =~ /^\d+$/

      return if warned_not_running?

      if n.nil?
        n = i
        i = 0
      end

      i = i ? i.to_i : 0
      n = n ? n.to_i : runtime.size

      Debugger.dump runtime.data, i, n, @console

      puts "Pointer at #{runtime.pointer}"

    end

    def move_command i

      raise ArgumentError unless i =~ /^\d+$/

      return if warned_not_running?

      i = i.to_i

      if i > runtime.pointer
        runtime.inc_pointer i - runtime.pointer
      elsif i < runtime.pointer
        runtime.dec_pointer runtime.pointer - i
      end

    end

    def set_command value

      raise ArgumentError unless value =~ /^\d+$/

      return if warned_not_running?

      runtime.set_value value.to_i

    end

    def warned_not_running?

      return false if @running

      @console.puts "Program is not runnning"

      true

    end

    def run_command_help
      "run the program and stop if a breakpoint condition is met"
    end

    def step_command_help
      [
        {desc:"execute one step (start the program if not running)"},
        {alias: 'CR', desc: "execute one step, when debugger is stepping"},
      ]
    end

    def stop_command_help
      "stop the running program"
    end

    def exit_command_help
      "exit the debugger (or ctrl-d)"
    end

    def b_command_help
      [{args: 'n', desc: "set breakpoint at line n"}]
    end

    def be_command_help
      [{alias: 'be', args: 'n', desc:
                  "stop execution when the current cell is equal to n"}]
    end

    def list_command_help
      "list all breakpoints"
    end

    def clear_command_help
      [{args: "n|c|all", desc: "clear n-th breakpoint, condition if 'c' or all"}]
    end

    def dump_command_help
      [
        {args: "[n]", desc: "dump first n values (all by default)"},
        {args: "i [n]", desc: "dump n values starting at index i"},
      ]
    end

    def set_command_help
      [{args: "value", desc: "set the value of current cell"}]
    end

    def move_command_help
      [{args: "i", desc: "move pointer to new position i"}]
    end

    def help_command_help
      "print this message"
    end

    def break_run? instruction_index

      return true if @break_condition == runtime.get_value

      line, _ = @compiled_code.mapping(instruction_index)

      return false unless line

      line += 1

      n = @breakpoints.bsearch {|x| x >= line}

      n == line

    end

    def display_current instruction_index

      line, col = @compiled_code.mapping(instruction_index)

      @console.puts
      @console.puts "%3d: #{@compiled_code.line(line)}" % (line + 1)
      @console.print "     "
      @console.print " " * col
      @console.puts "^"

    end

  end

end
