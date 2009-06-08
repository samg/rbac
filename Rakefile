require 'rake'
require 'rubygems'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => ['generate:cleanup', 'generator:generate', 'spec']

desc 'Run behavior specifications.'
Spec::Rake::SpecTask.new do |t|
  t.ruby_opts = ['-rspec/spec_helper']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :generator do
  desc "Cleans up the test app before running the generator"
  task :cleanup do
    FileList["generators/rbac/templates/**/*.*"].each do |each|
      file = "spec/rails_root/#{each.gsub("generators/rbac/templates/",'')}"
      File.delete(file) if File.exists?(file)
    end

    FileList["spec/rails_root/db/**/*"].each do |each|
      FileUtils.rm_rf(each)
    end
    FileUtils.rm_rf("spec/rails_root/vendor/plugins/rbac")
    FileUtils.mkdir_p("spec/rails_root/vendor/plugins")
    rbac_root = File.expand_path(File.dirname(__FILE__))
    system("ln -s #{rbac_root} spec/rails_root/vendor/plugins/rbac")
  end

  desc "Run the generator on the tests"
  task :generate do
    system "cd spec/rails_root && ./script/generate rbac && rake db:migrate db:test:prepare"
  end
end
