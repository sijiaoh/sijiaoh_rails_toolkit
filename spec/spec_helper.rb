# frozen_string_literal: true

require "sijiaoh_rails_toolkit"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random

  config.define_derived_metadata file_path: %r{/spec/system/} do |metadata|
    metadata[:type] = :system
  end
end
