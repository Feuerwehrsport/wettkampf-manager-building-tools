require_relative 'building_tools'

if ARGV[0] == "first"
  puts "Neuladen des Quellcodes (Teil 1)"
  system("ruby #{absolute("update_code.rb")}", out: $stdout, err: :out)
  system("ruby #{absolute("install.rb")}", out: $stdout, err: :out)
else
  puts "Neuladen des Quellcodes (Teil 2)"
  system("ruby #{absolute("update_code.rb")}", out: $stdout, err: :out)

  Dir.chdir "wettkampf-manager-master"
  system("bundle install --without development test staging", out: $stdout, err: :out)
  FileUtils.rm_rf("public/assets")

  system(production, "bundle exec rake assets:precompile", out: $stdout, err: :out)
  system(production, "bundle exec rake db:migrate", out: $stdout, err: :out)
  system(production, "bundle exec rake db:seed", out: $stdout, err: :out)
  system(production, "bundle exec rake import_suggestions", out: $stdout, err: :out)

  puts ""
  puts "Installation komplett"
end