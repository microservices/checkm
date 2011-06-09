
  class Manifest
    def self.parse str, args = {}
      Manifest.new str, args
    end

    attr_reader :version
    attr_reader :entries
    attr_reader :fields
    attr_reader :path

    def initialize checkm, args = {}
      @args = args
      @version = nil
      @checkm = checkm
      @lines = checkm.split "\n"
      @entries = []
      @eof = false
      @fields= nil
      @path = args[:path]
      @path ||= Dir.pwd
      parse_lines 
      # xxx error on empty entries?
      @lines.unshift('#%checkm_0.7') and @version = '0.7' if @version.nil?

    end

    def valid?
      return true if @entries.empty?
      not @entries.map { |e| e.valid? }.any? { |b| b == false }
    end

    def add path, args = {}
      line = Checkm::Entry.create path, args

      Checkm::Manifest.new [@lines, line].flatten.join("\n"), @args
    end

    def remove path
      Checkm::Manifest.new @lines.reject { |x| x =~ /^@?#{path}/ }.join("\n"), @args
    end

    def to_s
      @lines.join("\n")
    end

    def to_hash
      Hash[*@entries.map { |x| [x.sourcefileorurl, x] }.flatten]
    end

    private
