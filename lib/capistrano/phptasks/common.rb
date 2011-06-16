def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

def prompt_with_default(var, default, &block)
  set(var) do
    Capistrano::CLI.ui.ask("#{var} [#{default}] : ", &block)
  end
  set var, default if eval("#{var.to_s}.empty?")
end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

