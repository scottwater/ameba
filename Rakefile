require 'rubygems'
require 'rake'
require "spec"
require 'spec/rake/spectask'

namespace :spec do
  
  desc "Run all specs (requires a live database)"
  Spec::Rake::SpecTask.new(:all) do |spec|
    spec.pattern = "spec/**/*_spec.rb"
    spec.spec_opts = ['--color', '--format', 'p', '--loadby', 'mtime', '--reverse']
  end

  desc "Run a single functional spec (supply file_name, may require a live database)"
  task :f, :file_name do |t, args|
    sh "rake spec:all SPEC=spec/functional/#{args.file_name}_spec.rb"
  end

  desc "Run a single unit spec (supply file_name)"  
  task :u, :file_name do |t, args|
    sh "rake spec:all SPEC=spec/unit/#{args.file_name}_spec.rb"
  end  
  
  desc "Run all unit specs"
  task :unit do
    sh "rake spec:all SPEC=spec/unit/*_spec.rb"
  end  

  desc "Run all functional specs (requires a live database)"
  task :functional do
    sh "rake spec:all SPEC=spec/functional/*_spec.rb"
  end  
end


desc "Run all specs (requires a live database)"
task :default => 'spec:all'

task :install do
  sh 'gem install bundler'
  sh 'bundle install'
end

desc "Start RachSH in production mode"
task :rackshp do
  sh "RACK_ENV=production, AMEBA_SECRET_KEY='x' racksh"
end

task :mergejs do
  files = %w{code_highlighter.js csharp.js css.js html.js javascript.js ruby.js}
  
  File.open(File.join(File.dirname(__FILE__), 'public',  'js', 'code.js'), 'w') do |langs|
    files.each do  |name|  
      File.open(File.join(File.dirname(__FILE__), 'public',  'js', name), 'r') do |file|
        while line = file.gets
          langs.puts line
        end
        langs.puts
      end
    end
  end
  
end