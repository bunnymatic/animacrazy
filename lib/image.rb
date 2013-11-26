class Image

  DEFAULT_OPTS = {
    :background => 'black',
    :fill => 'white',
    :gravity => 'center',
    :font => 'Helvetica-Bold',
    :pointsize => 72,
    :size => '500x500',
    :delay => 60
  }

  def self.generate_animation(words, opts = {})
    opts.symbolize_keys!
    words = [words].flatten.compact
    fname,dir = generate_filename(words, opts.delete(:dest_dir))
    FileUtils.mkdir_p(dir)

    opts = DEFAULT_OPTS.merge(opts)
    opts[:pointsize] = 6 if opts[:pointsize].to_i < 6

    r = MojoMagick::convert(nil,fname) do |c|
      c.delay opts.delete(:delay)
      c.loop 0
      words.each do |w|
        opts[:label] = w
        c.image_block do
          opts.each do |opt,val|
            c.send(opt, val)
          end
        end
      end
    end
    fname
  end

  class << self
    private
    def generate_filename(words, destination = nil)
      dest_dir = destination || 'public/generated/'
      fname = temp_gif(sanitize_filename(words.join('')), dest_dir)
      [fname, dest_dir]
    end

    def temp_gif(pfx, dest_dir)
      fname = nil
      Dir::Tmpname.create([pfx,'.gif']) do |path|
        fname = File.join(dest_dir, File.basename(path))
      end
      fname
    end

    def sanitize_filename(fname)
      fname.gsub(/[[:punct:]]/,'').gsub(/\s+/,'_')[0..49]
    end
  end
end
