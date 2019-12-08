module Jekyll
  module ImagePathFilter
    def image_path_filter input
      baseurl = @context.registers[:site].config['baseurl']
      if (baseurl)
        input.sub(/^#{baseurl}\//, '')
      else
        input
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::ImagePathFilter)
