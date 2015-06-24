def absolute *path_args
  File.join(File.dirname(__FILE__), *path_args)
end

if ARGV[0] == "first"
  puts "first"
  puts `ruby #{absolute("update_code.rb")}`
  puts `ruby #{absolute("install.rb")}`
else
  puts "second"
  puts `ruby #{absolute("update_code.rb")}`
  puts "do some other stuff"
end