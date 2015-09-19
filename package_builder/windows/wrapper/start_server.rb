require_relative 'building_tools'

unless port_free?(platform_port)
  puts "Der Port #{platform_port} ist belegt!"
  puts "Läuft der Server eventuell schon?"
  exit 20
end

puts "Server starten"
puts "Zum Beenden bitte STRG + C drücken"
puts "Zum Beenden bitte STRG + C drücken"
puts "Zum Beenden bitte STRG + C drücken"

Dir.chdir "wettkampf-manager"
system(production, "bundle exec rails server -e production -p #{platform_port} -b 0.0.0.0", out: $stdout, err: :out)
