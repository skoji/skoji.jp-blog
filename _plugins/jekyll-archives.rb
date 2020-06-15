require "jekyll"

module Jekyll
  module Archives
    # Internal requires
    autoload :Archive, File.join(File.dirname(__FILE__), 'jekyll-archives/archive.rb')
    autoload :VERSION, File.join(File.dirname(__FILE__), 'jekyll-archives/version.rb')

    class Archives < Jekyll::Generator
      safe true

      DEFAULTS = {
        "layout"     => "archive",
        "enabled"    => [],
        "permalinks" => {
          "year"     => "/:year/",
          "month"    => "/:year/:month/",
          "day"      => "/:year/:month/:day/",
          "tag"      => "/tag/:name/",
          "category" => "/category/:name/"
        }
      }.freeze

      def initialize(config = nil)
        @config = if config["jekyll-archives"].nil?
                    DEFAULTS
                  else
                    Utils.deep_merge_hashes(DEFAULTS, config["jekyll-archives"])
                  end
      end

      def generate(site)
        @site = site
        @posts = site.posts
        @archives = []

        @site.config["jekyll-archives"] = @config

        read
        @site.pages.concat(@archives)

        @site.config["archives"] = @archives

        # adhoc patch
        monthly_archives_work = @archives
                                  .filter { |archive| archive.type == 'month' }
                                  .sort_by { |archive| archive.date }
                                  .map { |archive| ["#{archive.year.to_i}-#{archive.month.to_i}", archive] }
        first_year = monthly_archives_work.first[1].year.to_i
        first_month = monthly_archives_work.first[1].month.to_i
        last_year = monthly_archives_work.last[1].year.to_i
        last_month = monthly_archives_work.last[1].month.to_i
        monthly_archives_hash = monthly_archives_work.to_h
        monthly_archives = []
        for year in first_year..last_year
          year_monthly_archive = [];
          year_posts_count = 0;
          for month in 1..12
            next if (year == first_year && month < first_month)
            break if (year == last_year && month > last_month)
            archive = monthly_archives_hash["#{year}-#{month}"] || Archive.new(@site, {year: year.to_s, month: "%02d" % month}, 'month', [])
            year_posts_count += archive.posts.length
            year_monthly_archive.push(archive);
          end
          monthly_archives.push({"year" =>  year, "archives" => year_monthly_archive, "posts_count" => year_posts_count});
        end
        @site.config["monthly_archives"] = monthly_archives
      end

      # Read archive data from posts
      def read
        read_tags
        read_categories
        read_dates
      end

      def read_tags
        if enabled? "tags"
          tags.each do |title, posts|
            @archives << Archive.new(@site, title, "tag", posts)
          end
        end
      end

      def read_categories
        if enabled? "categories"
          categories.each do |title, posts|
            @archives << Archive.new(@site, title, "category", posts)
          end
        end
      end

      def read_dates
        years.each do |year, posts|
          @archives << Archive.new(@site, { :year => year }, "year", posts) if enabled? "year"
          months(posts).each do |month, posts|
            @archives << Archive.new(@site, { :year => year, :month => month }, "month", posts) if enabled? "month"
            days(posts).each do |day, posts|
              @archives << Archive.new(@site, { :year => year, :month => month, :day => day }, "day", posts) if enabled? "day"
            end
          end
        end
      end

      # Checks if archive type is enabled in config
      def enabled?(archive)
        @config["enabled"] == true || @config["enabled"] == "all" || if @config["enabled"].is_a? Array
                                                                       @config["enabled"].include? archive
        end
      end

      def tags
        @site.post_attr_hash("tags")
      end

      def categories
        @site.post_attr_hash("categories")
      end

      # Custom `post_attr_hash` method for years
      def years
        hash = Hash.new { |h, key| h[key] = [] }

        # In Jekyll 3, Collection#each should be called on the #docs array directly.
        if Jekyll::VERSION >= "3.0.0"
          @posts.docs.each { |p| hash[p.date.strftime("%Y")] << p }
        else
          @posts.each { |p| hash[p.date.strftime("%Y")] << p }
        end
        hash.values.each { |posts| posts.sort!.reverse! }
        hash
      end

      def months(year_posts)
        hash = Hash.new { |h, key| h[key] = [] }
        year_posts.each { |p| hash[p.date.strftime("%m")] << p }
        hash.values.each { |posts| posts.sort!.reverse! }
        hash
      end

      def days(month_posts)
        hash = Hash.new { |h, key| h[key] = [] }
        month_posts.each { |p| hash[p.date.strftime("%d")] << p }
        hash.values.each { |posts| posts.sort!.reverse! }
        hash
      end
    end
  end
end
