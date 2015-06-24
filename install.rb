def absolute *path_args
  File.join(File.dirname(__FILE__), *path_args)
end

if ARGV[0] == "first"
  puts "first"
  system("ruby", "#{absolute("update_code.rb")}", out: $stdout, err: :out)
  system("ruby", "#{absolute("install.rb")}", out: $stdout, err: :out)
else
  puts "second"
  system("ruby", "#{absolute("update_code.rb")}", out: $stdout, err: :out)
  puts "do some other stuff"
end