require_relative 'building_tools'


unless port_free?(platform_port)
  puts "Der Port #{platform_port} ist belegt. Bitte beenden Sie zuerste den Server."
  exit 21
end

if ARGV[0] == "first"
  overwrite = ""
  if File.exists? "wettkampf-manager-master/db/production.sqlite3"
    print "Es existiert bereits eine Datenbank. Soll diese Überschrieben werden? [j/n] "
    case STDIN.gets.strip
      when 'Y', 'y', 'j', 'J', 'yes'
        overwrite = " overwrite"
    end
  else
    overwrite = " overwrite"
  end

  puts "Neuladen des Quellcodes (Teil 1)"
  system("ruby #{absolute("update_code.rb")}", out: $stdout, err: :out)
  system("ruby #{absolute("install.rb")}#{overwrite}", out: $stdout, err: :out)
else
  overwrite = (ARGV[0] == "overwrite")

  puts "Neuladen des Quellcodes (Teil 2)"
  system("ruby #{absolute("update_code.rb")}", out: $stdout, err: :out)

  Dir.chdir "wettkampf-manager-master"
  FileUtils.rm_rf("db/production.sqlite3") if overwrite
  system("bundle install --without development test staging", out: $stdout, err: :out)
  FileUtils.rm_rf("public/assets")

  system(production, "bundle exec rake assets:precompile", out: $stdout, err: :out)
  system(production, "bundle exec rake db:migrate", out: $stdout, err: :out)

  if overwrite
    system(production, "bundle exec rake db:seed", out: $stdout, err: :out)
    system(production, "bundle exec rake import_suggestions", out: $stdout, err: :out)
  end

  puts ""
  puts "Installation komplett"
end