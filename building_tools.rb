require 'socket'
require 'fileutils'
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

def production
  { "RAILS_ENV" => "production" }
end

def platform_port
  windows? ? 80 : 3000
end

def port_free?(port)
  s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
  sa = Socket.sockaddr_in(port, "127.0.0.1")

  begin
    s.connect_nonblock(sa)
  rescue Errno::EINPROGRESS
    if IO.select(nil, [s], nil, 1)
      begin
        s.connect_nonblock(sa)
      rescue Errno::EISCONN
        return false
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        return true
      end
    end
  end

  return true
end