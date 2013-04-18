require 'fileutils'

# Module to assist in making sure that all files have the right license
# block as a header.

module LicenseHeader
  # For each language you can define three variables
  #
  # :pre will be prepended to the header
  # :each will be prepended to each line of the header
  # :post will be appended to the end of the file
  #
  # Only :each is required; if the other two are not provided they will be
  # ignored
  LANGUAGE_SYNTAX = { 
    :css        => { :pre => '/* ',  :each => ' * ', :post => '*/',  :exts => %w(.css .scss)            },
    :erb        => { :pre => '<%#',  :each => '',    :post => '%>',  :exts => %w(.erb)                  },
    :haml       => { :pre => '-#',   :each => '  ',                  :exts => %w(.haml)                 },
    :html       => { :pre => '<!--', :each => '',    :post => '-->', :exts => %w(.html)                 },
    :javascript => { :pre => '/* ',  :each => ' * ', :post => '*/',  :exts => %w(.js .json)             },
    :ruby       => {                 :each => '# ',                  :exts => %w(.rb .rake .coffee .pp) },
  }

  class Auditor
    attr_accessor :exceptions, :header, :verbose

    # Should set some sensible defaults here for license location, file
    # mappings, etc
    def initialize(configuration)
      @verbose = configuration[:verbose]
      @header = configuration[:header]
      @exceptions = configuration[:exceptions]
      initialize_headers
    end

    # Create a list of all files grouped by type and return the map
    def audit(*patterns)
      result = Hash.new { |h,k| h[k] = [] }

      Dir.glob(patterns).each do |entry|
        # Skip directories and files that match the exceptions
        next if File.directory?(entry)
        if @exceptions.any? { |ex| ex.match(entry) }
          $stderr.puts "Skipping #{entry}" if @verbose
          next
        end

        # Now to get down to business
        format = determine_format(entry)
        result[evaluate_header(entry, format)] << entry
      end

      return result
    end

    def evaluate_header(path, format)
      if format.nil? or format[:header].nil?
        :not_applicable
      else
        file_content = read_file(path)
        header_content = format[:header]
        index = file_content.find_index { |l| l =~ /---  [E]ND LICENSE_HEADER BLOCK  ---/ }
        if index.nil?
          :missing
        else
          file_heading = file_content[0, header_content.size]
          if file_heading.eql? header_content
            :valid
          else
            :present
          end
        end
      end
    end

    def process_files(action, *files)
      files.each do |file|
        format = determine_format(file)
        source_file = read_file(file)
        confirm = block_given? ? yield(file) : true
        if confirm and self.send(:"#{action.to_s}_license!", source_file, format)
          write_file(file, source_file)
        end
      end
    end

    def update_license!(source_file, format)
      remove_license!(source_file, format)
      header_content = format[:header]
      header_content.reverse.each { |line| source_file.insert(0, line) }
      return true
    end

    def remove_license!(source_file, format)
      end_of_license = source_file.find_index { |l| l =~ /---  [E]ND LICENSE_HEADER BLOCK  ---/ }
      if end_of_license.nil?
        return false
      else
        extra_lines = format[:post].nil? ? 1 : 2
        source_file.shift(end_of_license+extra_lines+1)
        return true
      end
    end

    private

    def determine_format(file)
      @headers.values.find { |syntax| syntax[:exts].include?(File.extname(file)) }
    end

    def read_file(file)
      File.read(file).chomp.split(/\n/)
    end

    def write_file(file, content)
      File.open("#{file}.tmp", "w") { |tmpfile| tmpfile.puts(content.join("\n")) }
      FileUtils.rm(file)
      FileUtils.mv("#{file}.tmp", file)
    end

    # Here we need to take the stock header and create two different versions -
    # one for Ruby based content using the # notation and another for
    # Javascript that uses /* */ syntax
    def initialize_headers
      @headers = LANGUAGE_SYNTAX.clone
      base = File.read(@header)
      # Break each line down so we can do easy manipulation to create our new
      # versions
      license_terms = base.split(/\n/)

      @headers.each_pair do |lang,syntax|
        syntax[:header] = []
        syntax[:header] << syntax[:pre] unless syntax[:pre].nil?
        syntax[:header] << "#{syntax[:each]}--- BEGIN LICENSE_HEADER BLOCK ---"
        syntax[:header] += license_terms.collect {|line| syntax[:each] + line }
        syntax[:header] << "#{syntax[:each]}---  #{'E'}ND LICENSE_HEADER BLOCK  ---"
        syntax[:header] << syntax[:post] unless syntax[:post].nil?
        syntax[:header] << ""
      end
    end
  end
end
