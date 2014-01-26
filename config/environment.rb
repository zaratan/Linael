ENV['LINAEL_ENV'] ||= 'development'
ROOT = File.join(File.dirname(__FILE__),'..')

require File.join(ROOT, 'config', 'boot')

Bundler.require(:default,ENV['LINAEL_ENV'])

require File.join(ROOT, 'config', 'application')

