Pry.config.color = true
Pry.config.editor = 'emacsclient -c '
Pry.config.prompt = proc do |obj, _level, _|
  prompt = ''
  prompt << "#{Rails.version}@" if defined?(Rails)
  prompt << RUBY_VERSION
  "#{prompt} (#{obj})> "
end
# Pry.hooks.add_hook(:before_session, 'simple-prompt') do |_output, _binding, pry|
#   pry.push_prompt Pry::SIMPLE_PROMPT
# end

# refs: https://github.com/deivid-rodriguez/pry-byebug#matching-byebug-behaviour
if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

# refs: https://github.com/pry/pry/wiki/FAQ#wiki-hirb
begin
  require 'hirb'
rescue LoadError
  puts 'no hirb'
end
if defined? Hirb
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |output, value|
        Hirb::View.view_or_page_output(value) || @old_print.call(output, value)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end

  Hirb.enable
end

# refs: https://github.com/pry/pry/wiki/FAQ#wiki-awesome_print
if defined? AwesomePrint
  begin
    require 'awesome_print'
    # Pry.config.print = proc { |output, value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output) }
    Pry.config.print = proc { |output, value| output.puts value.ai } #ページングなし
  rescue LoadError => err
    puts 'no awesome_print :('
    puts err
  end
end
