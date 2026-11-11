source 'https://rubygems.org'

gem "redis"
gem "multi_json"
gem "sinatra", ">= 2.2.0"
gem "sinatra-contrib"
gem "rest-client", ">= 1.7.3"
gem "rake", ">= 12.3.3"
gem 'unicorn'
gem "foreman"

# Pin transitive dependencies to patched releases to fix
# - CVE-2026-126080 / CVE-2026-126075 (activesupport, fixed in 8.1.4.1):
#   DoS in safe_constantize, XSS in MessagePack serializer
# - CVE-2026-125111 / -125108 / -125109 / -125110 (rack, fixed in 3.2.8)
# Pinning them explicitly prevents a future `bundle update` from silently
# regressing them back into the vulnerable range.
gem "rack", "~> 3.2.8"
gem "activesupport", "~> 8.1.4.1"

group :development do
  gem "shoulda", ">= 0"
  gem "bundler", ">= 2.2.33"
  gem "git", ">= 1.11.0"
  gem "test-unit", "~> 3.7"
end
