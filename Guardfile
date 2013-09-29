# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec , :cli => "--color", :keep_failed => false do
  watch('spec/spec_helper.rb') {"spec"}
  watch(%r{spec/core/*})
  watch(%r{lib/core/(.+)\.rb}) {|m| "spec/core/#{m[1]}_spec.rb"}
end

