require_relative 'building_tools'


Dir.chdir "wettkampf-manager"
system(production, "bundle exec rake backup_data_recurring", out: $stdout, err: :out)
