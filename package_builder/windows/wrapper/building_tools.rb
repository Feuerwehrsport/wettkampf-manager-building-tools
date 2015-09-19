require 'socket'
require 'fileutils'
require 'open-uri'
require 'tempfile'
require 'openssl'

def absolute *path_args
  File.join(File.dirname(__FILE__), *path_args)
end

def production
  { "RAILS_ENV" => "production" }
end

def platform_port
  80
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