require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/conditioner'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'conditioner' do
  self.developer 'niquola', 'niquola@gmail.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
  self.extra_deps         = [['activerecord','>= 2.3.5']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }


desc 'push gem to medapp'
namespace :medapp do
  task :push do
    gem_name =  File.basename(Dir['pkg/*.gem'].max)
    last_gem = File.join(File.dirname(__FILE__),'pkg',gem_name);
    server = 'demo'
    gem_copy_path = "/tmp/#{gem_name}"
    system "scp #{last_gem} #{server}:#{gem_copy_path}"
    system "ssh -t #{server} sudo gem install #{gem_copy_path}"  
  end
end
