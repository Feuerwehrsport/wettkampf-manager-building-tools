require 'open-uri'
require 'tempfile'
require 'zip'
require 'fileutils'
require 'openssl'


def update_code(options)
  tempfile = Tempfile.new('zip')
  tempfile.binmode

  # download master
  open(options[:zip_url], "rb", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |read_file|
    tempfile.write(read_file.read)
  end
  tempfile.close

  # remove old files
  keep_patterns = ["db/*.sqlite3", "log/*", "public/uploads/*"]
  Dir.glob("#{options[:extracted_path]}/**/*", File::FNM_DOTMATCH).select { |file| File.file?(file) }.reject do |file|
    keep_patterns.any? { |keep_pattern| File.fnmatch("#{options[:extracted_path]}/#{keep_pattern}", file) }
  end.each do |file|
    FileUtils.rm(file)
  end

  # unzip master
  Zip::File.open(tempfile.path) do |zip_file|
    zip_file.each do |entry|
      entry.extract(absolute("..", entry.name)) unless File.exists?(absolute("..", entry.name))
    end
  end
  tempfile.unlink
end

def windows?
  (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
end

def absolute *path_args
  File.join(File.dirname(__FILE__), *path_args)
end

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