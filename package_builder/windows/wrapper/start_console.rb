require_relative 'building_tools'


Dir.chdir "wettkampf-manager"
system(production, "bundle exec rails console -e production", out: $stdout, err: :out)
