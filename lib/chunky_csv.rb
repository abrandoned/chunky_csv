require 'thor'
require "chunky_csv/version"

module ChunkyCsv

  class FileSplitter
    attr_reader :chunk_number, :chunk_size, :input_filename, :output_directory

    def initialize( input_filename, chunk_size, output_directory )
      @chunk_number = 0
      @input_filename = input_filename
      @chunk_size = chunk_size
      @output_directory = output_directory
    end

    def split()
      batch = []
      IO.foreach( file ) do |line|
        batch << line

        if batch.size >= self.chunk_size
          flush_batch( batch )
        end
      end

      flush_batch( batch )
    end

    private

    def basename
      @basename ||= File.basename(self.input_filename)
    end

    def create_output_directory
      FileUtils.mkdir_p(output_directory)
    end

    def extension
      @extension ||= File.extname(self.input_filename)
    end

    def flush_batch( batch )
      unless File.directory?( output_directory )
        create_output_directory
      end

      if File.directory?( output_directory )
        File.open( next_chunk_filename, "w" ) do |file|
          batch.each do |line|
            file.print( line )
          end
        end
      end
    end

    def next_chunk_filename
      @chunk_number = @chunk_number + 1
      return File.expand_path(output_directory, "#{output_basename}_#{chunk_number}#{extension}")
    end

    def output_basename
      "#{basename}_chunk"
    end
  end
end
