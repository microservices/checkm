require 'time'
module Checkm  
  class Entry
    BASE_FIELDS = ['sourcefileorurl', 'alg', 'digest', 'length', 'modtime', 'targetfileorurl']
    attr_reader :values
  
    def self.create path, args = {}
      base = args[:base] || Dir.pwd
      alg = args[:alg] || 'md5'
      file = File.new File.join(base, path)
  
      "%s | %s | %s | %s | %s | %s" % [path, alg, Checkm.checksum(file, alg), File.size(file.path), file.mtime.utc.xmlschema, nil]
    end
  
    def initialize line, manifest = nil
      @line = line.strip
      @include = false
      @fields = BASE_FIELDS
      @fields = manifest.fields if manifest and manifest.fields
      @values = line.split('|').map { |s| s.strip }
      @manifest = manifest
    end
  
    def method_missing(sym, *args, &block)
      @values[@fields.index(sym.to_s.downcase) || BASE_FIELDS.index(sym.to_s.downcase)] rescue nil
    end
  
  
    def valid?
      return source_exists? && valid_checksum? && valid_multilevel? # xxx && valid_length? && valid_modtime?
    end
  
    private
    def source
      file = sourcefileorurl
      file = file[1..-1] if file =~ /^@/
      File.join(@manifest.path, file)
    end
  
    def source_exists?
      return File.exists? source
    end
  
    def valid_checksum?
      file = File.new source
      checksum = Checkm.checksum(file, alg) 
      checksum === true or checksum == digest
    end
  
  
    def valid_length?
      throw NotImplementedError
    end
  
    def valid_modtime?
      throw NotImplementedError
    end
  
    def valid_multilevel?
      return true unless sourcefileorurl =~ /^@/
      return Manifest.parse(open(source).read, File.dirname(source))
    end
  end
end
