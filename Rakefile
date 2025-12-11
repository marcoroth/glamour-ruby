# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require "rubocop/rake_task"

Minitest::TestTask.create
RuboCop::RakeTask.new

begin
  require "rake/extensiontask"

  PLATFORMS = %w[
    aarch64-linux-gnu
    aarch64-linux-musl
    arm-linux-gnu
    arm-linux-musl
    arm64-darwin
    x86-linux-gnu
    x86-linux-musl
    x86_64-darwin
    x86_64-linux-gnu
    x86_64-linux-musl
  ].freeze

  GO_PLATFORMS = {
    "aarch64-linux-gnu" => { goos: "linux", goarch: "arm64" },
    "aarch64-linux-musl" => { goos: "linux", goarch: "arm64" },
    "arm-linux-gnu" => { goos: "linux", goarch: "arm" },
    "arm-linux-musl" => { goos: "linux", goarch: "arm" },
    "arm64-darwin" => { goos: "darwin", goarch: "arm64" },
    "x86-linux-gnu" => { goos: "linux", goarch: "386" },
    "x86-linux-musl" => { goos: "linux", goarch: "386" },
    "x86_64-darwin" => { goos: "darwin", goarch: "amd64" },
    "x86_64-linux-gnu" => { goos: "linux", goarch: "amd64" },
    "x86_64-linux-musl" => { goos: "linux", goarch: "amd64" }
  }.freeze

  def go_version
    go_mod = File.read("go/go.mod")
    go_mod[/^go (\d+\.\d+)/, 1]
  end

  def detect_go_platform
    cpu = RbConfig::CONFIG["host_cpu"]
    os = RbConfig::CONFIG["host_os"]

    arch = case cpu
           when /aarch64|arm64/ then "arm64"
           when /x86_64|amd64/ then "amd64"
           else cpu
           end

    goos = case os
           when /darwin/ then "darwin"
           else "linux"
           end

    "#{goos}_#{arch}"
  end

  namespace :go do
    desc "Build Go archive for current platform"
    task :build do
      platform = detect_go_platform
      output_dir = "go/build/#{platform}"
      FileUtils.mkdir_p(output_dir)
      sh "cd go && CGO_ENABLED=1 go build -buildmode=c-archive -o build/#{platform}/libglamour.a ."
    end

    desc "Build Go archives for all platforms"
    task :build_all do
      GO_PLATFORMS.each_value do |env|
        output_dir = "go/build/#{env[:goos]}_#{env[:goarch]}"
        FileUtils.mkdir_p(output_dir)
        sh "cd go && CGO_ENABLED=1 GOOS=#{env[:goos]} GOARCH=#{env[:goarch]} go build -buildmode=c-archive -o build/#{env[:goos]}_#{env[:goarch]}/libglamour.a ."
      end
    end

    desc "Clean Go build artifacts"
    task :clean do
      FileUtils.rm_rf("go/build")
    end

    desc "Format Go source files"
    task :fmt do
      sh "gofmt -s -w go/"
    end
  end

  Rake::ExtensionTask.new do |ext|
    ext.name = "glamour"
    ext.ext_dir = "ext/glamour"
    ext.lib_dir = "lib/glamour"
    ext.source_pattern = "*.c"
    ext.gem_spec = Gem::Specification.load("glamour.gemspec")
    ext.cross_compile = true
    ext.cross_platform = PLATFORMS
  end

  task compile: "go:build"

  namespace "gem" do
    task "prepare" do
      require "rake_compiler_dock"

      sh "bundle config set cache_all true"

      gemspec_path = File.expand_path("./glamour.gemspec", __dir__)
      spec = eval(File.read(gemspec_path), binding, gemspec_path)

      RakeCompilerDock.set_ruby_cc_version(spec.required_ruby_version.as_list)
    rescue LoadError
      abort "rake_compiler_dock is required for this task"
    end

    PLATFORMS.each do |platform|
      desc "Build the native gem for #{platform}"
      task platform => "prepare" do
        require "rake_compiler_dock"

        env = GO_PLATFORMS[platform]

        build_script = <<~BASH
          curl -sSL https://go.dev/dl/go#{go_version}.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
          export PATH=$PATH:/usr/local/go/bin && \
          cd go && \
          mkdir -p build/#{env[:goos]}_#{env[:goarch]} && \
          CGO_ENABLED=1 GOOS=#{env[:goos]} GOARCH=#{env[:goarch]} go build -buildmode=c-archive -o build/#{env[:goos]}_#{env[:goarch]}/libglamour.a . && \
          cd .. && \
          bundle --local && \
          rake native:#{platform} gem RUBY_CC_VERSION='#{ENV.fetch("RUBY_CC_VERSION", nil)}'
        BASH

        RakeCompilerDock.sh(build_script, platform: platform)
      end
    end
  end
rescue LoadError => e
  desc "Compile task not available (rake-compiler not installed)"
  task :compile do
    puts e
    abort <<~MESSAGE

      rake-compiler is required for this task.

      Are you running `rake` using `bundle exec rake`?

      Otherwise:
        * try to run bundle install
        * add it to your Gemfile
        * or install it with: gem install rake-compiler
    MESSAGE
  end
end

task :rbs_inline do
  require "open3"

  command = "bundle exec rbs-inline --opt-out --output=sig/ lib/"

  _stdout, stderr, status = Open3.capture3(command)

  puts "Running `#{command}`"

  if stderr.strip == "🎉 Generated 0 RBS files under sig/"
    puts "RBS files in sig/ are up to date"
    exit status.exitstatus
  else
    puts "RBS files in sig/ are not up to date"
    exit 1
  end
end

task default: %i[test rubocop compile]
