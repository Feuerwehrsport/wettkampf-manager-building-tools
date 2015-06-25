require_relative 'building_tools'

update_code(
  zip_url: "https://github.com/Feuerwehrsport/wettkampf-manager/archive/master.zip",
  extracted_path: absolute("..", "wettkampf-manager-master"),
  keep_patterns: ["db/*.sqlite3", "log/*", "/public/uploads/*"],
)

update_code(
  zip_url: "https://github.com/Feuerwehrsport/wettkampf-manager-building-tools/archive/master.zip",
  extracted_path: absolute("..", "wettkampf-manager-building-tools-master"),
  keep_patterns: [],
)

if windows?
  Dir.glob(absolute("..", "*.bat")) do |file|
    FileUtils.rm(file)
  end
  Dir.glob(absolute("..", "wettkampf-manager-building-tools-master", "start_scripts_windows", "/*.bat")) do |file|
    FileUtils.cp file, absolute("..", File.basename(file))
  end
else
  Dir.glob(absolute("..", "*.sh")) do |file|
    FileUtils.rm(file)
  end
  Dir.glob(absolute("..", "wettkampf-manager-building-tools-master", "start_scripts_linux", "/*.sh")) do |file|
    FileUtils.cp file, absolute("..", File.basename(file))
    FileUtils.chmod "+x", absolute("..", File.basename(file))
  end
end