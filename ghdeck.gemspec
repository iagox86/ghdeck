
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ghdeck/version"

Gem::Specification.new do |spec|
  spec.name          = "ghdeck"
  spec.version       = GHDeck::VERSION
  spec.authors       = ["iagox86"]
  spec.email         = ["ron-git@skullsecurity.org"]

  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = ''

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
	spec.add_development_dependency("test-unit", "~> 3.2.7")
	spec.add_development_dependency("simplecov", "~> 0.15.1")

	spec.add_dependency("sinatra", "~> 2.0")
	spec.add_dependency("rack-robustness", "~> 1.1.0")
end
