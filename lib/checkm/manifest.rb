module Checkm
  class Manifest
    BASE_FIELDS = ['sourcefileorurl', 'alg', 'digest', 'length', 'modtime', 'targetfileorurl']
  
    attr_reader :source
    attr_reader :eof

    attr_reader :fields
    attr_reader :path
    attr_accessor :entries
  
    def initialize str_io_or_file = '', args = {}
      @source = str_io_or_file
      @args = args
      @entries = []

      @eof = args[:eof]
      @version = args[:version]
      @fields = args[:fields]

      @path = args[:path]
      @path ||= Dir.pwd
  
      parse_lines(@source) 
    end

    def version
      @version || "0.7"
    end

    def fields
      @fields || BASE_FIELDS
    end

    def valid?
      return true if @entries.empty?
      not @entries.map { |e| e.valid? }.any? { |b| b == false }
    end
  
    def add path_or_entry, args = {}
      args[:options] ||= options_for_entries

      @entries << Checkm::Entry.create(path_or_entry, args) 
    end

    alias_method :<<, :add
  
    def remove path_or_entry
      path = path_or_entry.path if path_or_entry.respond_to? :path
      path ||= path_or_entry[0] if path_or_entry.is_a? Entry or path_or_entry.is_a? Array
      path ||= path_or_entry

      @entries.reject! { |x| x[0] =~ /^@?#{path}/ }
    end

    alias_method :-, :remove
  
    def to_s
      lines = []

      lines << "#%checkm_#{version}"
      lines << "#%fields | #{ @fields.join(" | ") }" if @fields

      lines += entries.map(&:to_s)

      lines << '#%eof' if eof

      lines.join("\n")
    end

    def save
      raise unless @source.is_a? File

      File.open(@source.path, 'w') { |f| f.write(self.to_s) }
    end
  
    def to_hash
      Hash[*@entries.map { |x| [x.sourcefileorurl, x] }.flatten]
    end
  
    private
    def source_text
      return if @source_text

      case source 
        when IO
          @source_text ||= source.read
        when String 
          if source.is_a?(String) and (File.exists?(source) or source =~ /:\/\//)
            @source_text ||= open(source).read
          end
      end
      @source_text ||= source

      @source_text
    end

    def parse_lines str
      source_text.split("\n").each do |line|
        case line
          when /^#%/
            parse_header line
          when /^#/
            parse_comment line
          when /^$/
  
          when /^@/
            parse_manifest line     
          else
            parse_entry line     
        end
      end
    end
  
    def parse_header line
      case line
        when /^#%checkm/
          match = /^#%checkm_(\d+)\.(\d+)/.match line
          @version ||= "#{match[1]}.#{match[2]}" if match
        when /^#%eof/
          @eof ||= true
        when /^#%fields/
          list = line.split('|')
          list.shift
          @fields ||= list.map { |v| v.strip }
        when /^#%prefix/
  
        when /^#%profile/
  
      end
    end
    
    def parse_comment line
  
    end
  
    def parse_entry line
      @entries << Entry.new(line, options_for_entries )
    end

    def options_for_entries
      { :path => path, :fields => fields, :manifest => self }
    end

    def parse_manifest line
      @entries << Manifest.new(line[/^@([^|]+)/].strip.gsub(/^@/, ''))
    end
  end
end
