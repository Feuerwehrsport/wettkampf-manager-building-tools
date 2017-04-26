require_relative 'building_tools'


Dir.chdir 'wettkampf-manager'
system(production, 'bundle exec rails runner -e production "API::Runner.new"', out: $stdout, err: :out)
