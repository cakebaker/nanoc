module Nanoc3

  # A Nanoc3::Router is an abstract superclass that determines the paths of
  # page and asset representations, both the path on the disk (relative to the
  # site's output directory) and the path as it appears on the web site.
  class Router < Plugin

    # Creates a new router for the given site.
    def initialize(site)
      @site = site
    end

    # Sets the identifiers for this router.
    def self.identifiers(*identifiers)
      Nanoc3::Router.register(self, *identifiers)
    end

    # Sets the identifier for this router.
    def self.identifier(identifier)
      Nanoc3::Router.register(self, identifier)
    end

    # Registers the given class as a router with the given identifier.
    def self.register(class_or_name, *identifiers)
      Nanoc3::Plugin.register(Nanoc3::Router, class_or_name, *identifiers)
    end

    # Returns the routed path for the given page representation, including the
    # filename and the extension. It should start with a slash, and should be
    # relative to the web root (i.e. should not include any references to the
    # output directory). There is no need to let this method handle custom
    # paths.
    #
    # Subclasses must implement this method.
    def path_for_page_rep(page_rep)
      raise NotImplementedError.new("Nanoc3::Router subclasses must implement #path_for_page_rep.")
    end

    # Returns the routed path for the given asset representation, including
    # the filename and the extension. It should start with a slash, and should
    # be relative to the web root (i.e. should not include any references to
    # the output directory). There is no need to let this method handle custom
    # paths.
    #
    # Subclasses must implement this method.
    def path_for_asset_rep(asset_rep)
      raise NotImplementedError.new("Nanoc3::Router subclasses must implement #path_for_asset_rep.")
    end

    # Returns the web path for the given page or asset representation, i.e.
    # the page or asset rep's custom path or routed path with index filenames
    # stripped.
    def path_for(rep)
      # Get actual path
      path ||= rep.item.attribute_named(:custom_path)
      if rep.is_a?(Nanoc3::PageRep) # Page rep
        path ||= path_for_page_rep(rep)
      else # Asset rep
        path ||= path_for_asset_rep(rep)
      end

      # Try stripping each index filename
      @site.config[:index_filenames].each do |index_filename|
        if path[-index_filename.length..-1] == index_filename
          # Strip and stop
          path = path[0..-index_filename.length-1]
          break
        end
      end

      # Return possibly stripped path
      path
    end

    # Returns the disk path for the given page or asset representation, i.e.
    # the page or asset's custom path or routed path relative to the output
    # directory.
    def raw_path_for(rep)
      @site.config[:output_dir] + (
        rep.item.attribute_named(:custom_path) ||
        (rep.is_a?(Nanoc3::PageRep) ? path_for_page_rep(rep) : path_for_asset_rep(rep))
      )
    end

  end

end