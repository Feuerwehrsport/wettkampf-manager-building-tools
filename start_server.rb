require_relative 'building_tools'

unless port_free?(platform_port)
  puts "Der Port #{platform_port} ist belegt!"
  puts "Läuft der Server eventuell schon?"
  exit 20
end

puts "Server starten"

Dir.chdir "wettkampf-manager-master"
system(production, "bundle exec rails server -e production -p #{platform_port} -b 0.0.0.0 -d", out: $stdout, err: :out)
