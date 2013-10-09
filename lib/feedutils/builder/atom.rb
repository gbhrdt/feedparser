
module FeedUtils

class AtomFeedBuilder

  include LogUtils::Logging

  def initialize( atom_feed )
    @feed = build_feed( atom_feed )
  end

  def to_feed
    @feed
  end

  def self.build( atom_feed )
    feed = self.new( atom_feed )
    feed.to_feed
  end


  def build_feed( atom_feed )
    feed = Feed.new
    ## feed.object = atom_feed  # not use for now
    feed.format = 'atom'

    feed.title  = atom_feed.title.content
    logger.debug "  atom | title.content  >#{atom_feed.title.content}< : #{atom_feed.title.content.class.name}"

    if atom_feed.updated
      # NOTE: empty updated.content e.g.  used by google groups feed
      #   will return nil : NilClass
      
      ## convert from time to to_datetime  (avoid errors on windows w/ builtin rss lib)
      
      feed.updated =  atom_feed.updated.content.nil?  ? nil : atom_feed.updated.content.to_datetime  #  .utc.strftime( "%Y-%m-%d %H:%M" )
      logger.debug "  atom | updated.content  >#{atom_feed.updated.content}< : #{atom_feed.updated.content.class.name}"
    end

    if atom_feed.generator
      feed.generator =  atom_feed.generator.content
      logger.debug "  atom | generator.content  >#{atom_feed.generator.content}< : #{atom_feed.generator.content.class.name}"

      # pp atom_feed.generator
      feed.generator_version = atom_feed.generator.version
      feed.generator_uri     = atom_feed.generator.uri
      logger.debug "  atom | generator.version  >#{atom_feed.generator.version}< : #{atom_feed.generator.version.class.name}"
      logger.debug "  atom | generator.uri      >#{atom_feed.generator.uri}< : #{atom_feed.generator.uri.class.name}"
    end

    if atom_feed.subtitle
      feed.title2 =  atom_feed.subtitle.content
      logger.debug "  atom | subtitle.content  >#{atom_feed.subtitle.content}< : #{atom_feed.subtitle.content.class.name}"
    end


    items = []
    atom_feed.items.each do |atom_item|
      items << build_feed_item( atom_item )
    end
    feed.items = items

    feed # return new feed
  end # method build_feed_from_atom

  def build_feed_item( atom_item )
    item = Item.new   # Item.new
    ## item.object = atom_item  # not used for now

    item.title     = atom_item.title.content
    item.url       = atom_item.link.href

    logger.debug "  atom | item.title.content: >#{atom_item.title.content}< : #{atom_item.title.content.class.name}"
    logger.debug "  atom | item.link.href: >#{atom_item.link.href}< : #{atom_item.link.href.class.name}"


    if atom_item.updated
      ## change time to utc if present? why? why not?
      #  --  .utc.strftime( "%Y-%m-%d %H:%M" )

      ## convert from time to to_datetime  (avoid errors on windows w/ builtin rss lib)

      item.updated    =  atom_item.updated.content.nil? ? nil : atom_item.updated.content.to_datetime
      logger.debug "  atom | item.updated.content  >#{atom_item.updated.content}< : #{atom_item.updated.content.class.name}"
    end

    if atom_item.published
      ## convert from time to to_datetime  (avoid errors on windows w/ builtin rss lib)

      item.published   =  atom_item.published.content.nil? ? nil : atom_item.published.content.to_datetime
      logger.debug "  atom | item.published.content  >#{atom_item.published.content}< : #{atom_item.published.content.class.name}"
    end


    item.guid       =  atom_item.id.content
    logger.debug "  atom | item.id.content: >#{atom_item.id.content}< : #{atom_item.id.content.class.name}"

    if atom_item.content
      item.content = atom_item.content.content
    end

    if atom_item.summary
      item.summary = atom_item.summary.content
    end

    item
  end # method build_feed_item

end # AtomFeedBuilder
end # FeedUtils