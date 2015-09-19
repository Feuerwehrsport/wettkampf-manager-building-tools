require_relative 'building_tools'

unless port_free?(platform_port)
  puts "Der Port #{platform_port} ist belegt. Bitte beenden Sie zuerste den Server."
  exit 21
end


overwrite = false
if File.exists? "wettkampf-manager-master/db/production.sqlite3"
  print "Es existiert bereits eine Datenbank. Soll diese Überschrieben werden? [j/n] "
  case STDIN.gets.strip
    when 'Y', 'y', 'j', 'J', 'yes'
      overwrite = true
  end
else
  overwrite = true
end

Dir.chdir "wettkampf-manager"
FileUtils.rm_rf("db/production.sqlite3") if overwrite

system(production, "bundle exec rake assets:precompile", out: $stdout, err: :out)
system(production, "bundle exec rake db:migrate", out: $stdout, err: :out)

if overwrite
  system(production, "bundle exec rake db:seed", out: $stdout, err: :out)
  system(production, "bundle exec rake import_suggestions", out: $stdout, err: :out)
end

puts ""
puts "Installation komplett"
