require 'time'
module Checkm  
  class Entry
    def self.create file_or_path, args = {}
      return file_or_path if file_or_path.is_a? Entry

      options = args.delete(:options) || {}
      path = options[:path] || Dir.pwd

      file = file_or_path if file.is_a? File
      file ||= File.open(File.expand_path(file_or_path, path))

      args[:sourcefileorurl] = File.expand_path(file.path).gsub(path + "/", '') if file.respond_to? :path
      args[:alg] ||= 'md5'
      args[:digest] ||= Checkm.checksum(file, args[:alg])
      args[:length] ||= File.size(file.path)
      args[:modtime] ||= file.mtime.utc.xmlschema

      Checkm::Entry.new(args, options)
    end

    attr_reader :values
    attr_reader :fields
  
    def initialize source, options = {}
      @fields = options[:fields] || Manifest::BASE_FIELDS 
      @path = options[:path]
      @path ||= Dir.pwd

      @values = case source
      when Hash
        tmp = {}
        source.each { |k, v| tmp[k.to_s.downcase.to_sym] = v }
        @fields.map { |k| source[k.to_s.downcase.to_sym] }
      when Array
        source
      when String
        source.split("|").map { |x| x.strip }
      end
    end

    def [] idx
      values[idx] rescue nil
    end

    def []= idx, value
      values[idx] = value rescue nil
    end

    def to_s
      values.join(" | ")
    end
  
    def method_missing(sym, *args, &block)
      self[@fields.map { |x| x.downcase }.index(sym.to_s.downcase) || Manifest::BASE_FIELDS.map { |x| x.downcase }.index(sym.to_s.downcase)]
    end
  
    def valid?
      return File.exists?(source) && valid_checksum? # xxx && valid_length? && valid_modtime?
    end
  
    private
    def source
      file = sourcefileorurl
      File.join(@path, file)
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
  end
end
