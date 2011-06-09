require 'checkm/manifest'
require 'checkm/entry'

module Checkm
  # Size (in bytes) to read (in chunks) to compute checksums
  CHUNK_SIZE = 8*1024*1024

  # Compute the checksum 'alg' for a file
  # @param [File] file
  # @param [String] alg md5, sha1, sha256, dir
  def self.checksum file, alg
      digest_alg = case alg
        when nil
          return true
        when /md5/
           Digest::MD5.new 
        when /sha1/
          Digest::SHA1.new
        when /sha256/
          Digest::SHA2.new(256)
        when /dir/
          return File.directory? file
        else 
          return false      
      end

      while not file.eof? and chunk = file.readpartial(CHUNK_SIZE)
        digest_alg << chunk
      end
      digest_alg.hexdigest
  end
end
