require 'uri'

BAD_DIVS = {
  :class => ['greybox', 'metadata', 'social-inner', 'breadcrumb', 'embedded-image'],
  :id => ['breadcrumb']
}

RemoveInternalLinks = lambda do |env|
  node = env[:node]

  if env[:node_name] == 'a'
    uri = URI.parse(node[:href])
    unless uri.kind_of?(URI::HTTP)
      node.replace node.text
    end
  end
end

RemoveHiddenThings = lambda do |env|
  node = env[:node]

  if node[:class] && node[:class].split(' ').include?('hide')
    node.remove
  end
end


DestroyBadDivs = lambda do |env|
  node = env[:node]
  if env[:node_name] == 'div'
    BAD_DIVS.each_key do |k|
      if node[k]
        if (node[k].split(' ') & BAD_DIVS[k]).any?
          node.remove
          return
        end
      end
    end
  end
end


class Sanitize
  module HubsConfig

    DEFAULT = {
      :elements => %w[
        p a
        li ul br
        table tr th td
        embed embed-inline
        h1 h2 h3 h4 h5 h6
      ],

      :attributes => {
        'a'    => ['href', 'title'],
      },

      :remove_contents => ['button'],

      # Order is important.
      :transformers => [RemoveInternalLinks, DestroyBadDivs, RemoveHiddenThings],

      :whitespace_elements => {},

      :output => :html
    }
  end
end
