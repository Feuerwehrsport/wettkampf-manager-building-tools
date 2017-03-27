# -*- encoding: utf-8 -*-
# stub: win32console 1.3.2 x86-mingw32 lib

Gem::Specification.new do |s|
  s.name = "win32console".freeze
  s.version = "1.3.2"
  s.platform = "x86-mingw32".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gonzalo Garramuno".freeze, "Justin Bailey".freeze, "Luis Lavena".freeze]
  s.date = "2012-05-14"
  s.description = "Win32::Console allows controling the windows command line terminal\nthru an OO-interface. This allows you to query the terminal (find\nits size, characters, attributes, etc). The interface and functionality\nshould be identical to Perl's counterpart.\n\nA port of Perl's Win32::Console and Win32::Console::ANSI modules.\n\nThis gem packages Gonzalo Garramuno's Win32::Console project, and includes\na compiled binary for speed. The Win32::Console project's home can be\nfound at:\n\n  http://rubyforge.org/projects/win32console".freeze
  s.email = ["ggarra@advancedsl.com.ar".freeze, "jgbailey@gmail.com".freeze, "luislavena@gmail.com".freeze]
  s.extra_rdoc_files = ["History.txt".freeze, "Manifest.txt".freeze, "README.txt".freeze, "extra/Console.rdoc".freeze, "extra/Console_ANSI.rdoc".freeze]
  s.files = ["History.txt".freeze, "Manifest.txt".freeze, "README.txt".freeze, "extra/Console.rdoc".freeze, "extra/Console_ANSI.rdoc".freeze]
  s.homepage = "http://rubyforge.org/projects/winconsole".freeze
  s.rdoc_options = ["--main".freeze, "README.txt".freeze, "--exclude".freeze, "ext".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6".freeze)
  s.rubyforge_project = "winconsole".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Win32::Console allows controling the windows command line terminal thru an OO-interface".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.10"])
      s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 0.7.0"])
      s.add_development_dependency(%q<mocha>.freeze, [">= 0.10.5"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 2.9.0"])
      s.add_development_dependency(%q<rspec-core>.freeze, [">= 2.9.0"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.0"])
    else
      s.add_dependency(%q<rdoc>.freeze, ["~> 3.10"])
      s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.7.0"])
      s.add_dependency(%q<mocha>.freeze, [">= 0.10.5"])
      s.add_dependency(%q<rspec>.freeze, [">= 2.9.0"])
      s.add_dependency(%q<rspec-core>.freeze, [">= 2.9.0"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<rdoc>.freeze, ["~> 3.10"])
    s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.7.0"])
    s.add_dependency(%q<mocha>.freeze, [">= 0.10.5"])
    s.add_dependency(%q<rspec>.freeze, [">= 2.9.0"])
    s.add_dependency(%q<rspec-core>.freeze, [">= 2.9.0"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.0"])
  end
end
