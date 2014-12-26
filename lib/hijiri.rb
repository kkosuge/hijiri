require "hijiri/version"
require "hijiri/parser"

module Hijiri
  class << self
    def parse(text)
      Parser.new(text).parse
    end
  end
end
