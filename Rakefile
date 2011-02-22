# encoding: utf-8

require 'rubygems'
require 'rake'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "httpdoc"
    gem.summary = gem.description = %Q{Simple documentation generator for publishing APIs from Rails applications.}
    gem.email = "alex@bengler.no"
    gem.homepage = "http://github.com/origo/httpdoc"
    gem.authors = ["Alexander Staubo"]
    gem.has_rdoc = false
    gem.require_paths = ["lib"]
    gem.test_files = []
    gem.files = FileList[%W(
      README.markdown
      VERSION
      LICENSE
      lib/httpdoc.rb
      lib/httpdoc/**/*
    )]
    gem.add_dependency 'RedCloth'
    gem.executables = %w(
      httpdoc
    )
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  $stderr << "Warning: Gem-building tasks are not included as Jeweler (or a dependency) not available. Install it with: `gem install jeweler`.\n"
end
