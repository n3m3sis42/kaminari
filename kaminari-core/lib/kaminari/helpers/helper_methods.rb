# frozen_string_literal: true
require 'i18n'

module Kaminari
  module Helpers

    # The Kaminari::Helpers::UrlHelper module provides useful methods for
    # generating a path or url to a particlar page. A class must implement the
    # following methods:
    #
    #   * <tt>url_for</tt>: A method that generates an actual path
    #   * <tt>params</tt>: A method that returns query string parameters
    #
    # A normal Rails controller implements both of the methods, which makes it
    # very easy to use this module:
    #
    # ==== Examples
    #
    #   class UsersController < ApplicationController
    #     include Kaminari::Helpers::UrlHelper
    #
    #     def index
    #      @users = User.page(1)
    #
    #      path_to_next_page(@items)
    #      # => /items?page=2
    #     end
    #   end
    #
    module UrlHelper

      # A helper that calculates the url to the next page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= next_page_url @items %>
      #   #-> http://www.example.org/items?page=2
      #
      # It will return `nil` if there is no next page.
      def next_page_url(scope, options = {})
        Kaminari::Helpers::NextPage.new(self, options.reverse_merge(current_page: scope.current_page)).url if scope.next_page
      end
      alias path_to_next_url next_page_url

      # A helper that calculates the url to the previous page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= prev_page_url @items %>
      #   #-> http://www.example.org/items
      #
      # It will return `nil` if there is no previous page.
      def prev_page_url(scope, options = {})
        Kaminari::Helpers::PrevPage.new(self, options.reverse_merge(current_page: scope.current_page)).url if scope.prev_page
      end
      alias previous_page_url     prev_page_url
      alias url_to_prev_page      prev_page_url
      alias url_to_previous_page  prev_page_url

      # A helper that calculates the path to the next page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= path_to_next_page @items %>
      #   #-> /items?page=2
      #
      # It will return `nil` if there is no next page.
      def path_to_next_page(scope, options = {})
        Kaminari::Helpers::NextPage.new(self, options.reverse_merge(current_page: scope.current_page)).path if scope.next_page
      end
      alias next_page_path path_to_next_page

      # A helper that calculates the path to the previous page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= path_to_prev_page @items %>
      #   #-> /items
      #
      # It will return `nil` if there is no previous page.
      def path_to_previous_page(scope, options = {})
        Kaminari::Helpers::PrevPage.new(self, options.reverse_merge(current_page: scope.current_page)).path if scope.prev_page
      end
      alias path_to_prev_page path_to_previous_page
      alias prev_page_path path_to_previous_page
    end

    # The Kaminari::Helpers::TagHelper module provides methods that generates
    # an anchor or rel tag. In order to use this module, a class that includes
    # this module must implement the <tt>link_to</tt> method. The easiest way
    # to do this is to include the <tt>ActionView::Helpers::UrlHelper</tt>
    # module.
    module TagHelper
      include UrlHelper

      # A simple "Twitter like" pagination link that creates a link to the previous page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= link_to_previous_page @items, 'Previous Page' %>
      #
      # Ajax:
      #
      #   <%= link_to_previous_page @items, 'Previous Page', remote: true %>
      #
      # By default, it renders nothing if there are no more results on the previous page.
      # You can customize this output by passing a block.
      #
      #   <%= link_to_previous_page @users, 'Previous Page' do %>
      #     <span>At the Beginning</span>
      #   <% end %>
      #
      def link_to_previous_page(scope, name, **options)
        prev_page = path_to_prev_page(scope, options)

        options.except! :params, :param_name
        options[:rel] ||= 'prev'

        if prev_page
          link_to name, prev_page, options
        else
          yield if block_given?
        end
      end
      alias link_to_prev_page link_to_previous_page

      # A simple "Twitter like" pagination link that creates a link to the next page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= link_to_next_page @items, 'Next Page' %>
      #
      # Ajax:
      #
      #   <%= link_to_next_page @items, 'Next Page', remote: true %>
      #
      # By default, it renders nothing if there are no more results on the next page.
      # You can customize this output by passing a block.
      #
      #   <%= link_to_next_page @users, 'Next Page' do %>
      #     <span>No More Pages</span>
      #   <% end %>
      #
      def link_to_next_page(scope, name, **options)
        next_page = path_to_next_page(scope, options)

        options.except! :params, :param_name
        options[:rel] ||= 'next'

        if next_page
          link_to name, next_page, options
        else
          yield if block_given?
        end
      end

      # Renders rel="next" and rel="prev" links to be used in the head.
      #
      # ==== Examples
      # Basic usage:
      #
      #   In head:
      #   <head>
      #     <title>My Website</title>
      #     <%= yield :head %>
      #   </head>
      #
      #   Somewhere in body:
      #   <% content_for :head do %>
      #     <%= rel_next_prev_link_tags @items %>
      #   <% end %>
      #
      #   #-> <link rel="next" href="/items/page/3" /><link rel="prev" href="/items/page/1" />
      #
      def rel_next_prev_link_tags(scope, options = {})
        next_page = path_to_next_page(scope, options)
        prev_page = path_to_prev_page(scope, options)

        output = String.new
        output << %Q|<link rel="next" href="#{next_page}"></link>| if next_page
        output << %Q|<link rel="prev" href="#{prev_page}"></link>| if prev_page
        output.html_safe
      end
    end

    module ViewHeler #:nodoc:
      # Renders a helpful message with numbers of displayed vs. total entries.
      # Ported from mislav/will_paginate
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= page_entries_info @posts %>
      #   #-> Displaying posts 6 - 10 of 26 in total
      #
      # By default, the message will use the humanized class name of objects
      # in collection: for instance, "project types" for ProjectType models.
      # The namespace will be cutted out and only the last name will be used.
      # Override this with the <tt>:entry_name</tt> parameter:
      #
      #   <%= page_entries_info @posts, entry_name: 'item' %>
      #   #-> Displaying items 6 - 10 of 26 in total
      def page_entries_info(collection, entry_name: nil)
        entry_name = if entry_name
                       entry_name.pluralize(collection.size, I18n.locale)
                     else
                       collection.entry_name(count: collection.size).downcase
                     end

        if collection.total_pages < 2
          I18n.t('helpers.page_entries_info.one_page.display_entries', entry_name: entry_name, count: collection.total_count)
        else
          I18n.t('helpers.page_entries_info.more_pages.display_entries', entry_name: entry_name, first: collection.offset_value + 1, last: [collection.offset_value + collection.limit_value, collection.total_count].min, total: collection.total_count)
        end.html_safe
      end
    end

    module PaginationHelper #:nodoc:
      # A helper that renders the pagination links.
      #
      #   <%= paginate @articles %>
      #
      # ==== Options
      # * <tt>:window</tt> - The "inner window" size (4 by default).
      # * <tt>:outer_window</tt> - The "outer window" size (0 by default).
      # * <tt>:left</tt> - The "left outer window" size (0 by default).
      # * <tt>:right</tt> - The "right outer window" size (0 by default).
      # * <tt>:params</tt> - url_for parameters for the links (:controller, :action, etc.)
      # * <tt>:param_name</tt> - parameter name for page number in the links (:page by default)
      # * <tt>:remote</tt> - Ajax? (false by default)
      # * <tt>:paginator_class</tt> - Specify a custom Paginator (Kaminari::Helpers::Paginator by default)
      # * <tt>:template</tt> - Specify a custom template renderer for rendering the Paginator (receiver by default)
      # * <tt>:ANY_OTHER_VALUES</tt> - Any other hash key & values would be directly passed into each tag as :locals value.
      def paginate(scope, paginator_class: Kaminari::Helpers::Paginator, template: nil, **options)
        options[:total_pages] ||= scope.total_pages
        options.reverse_merge! current_page: scope.current_page, per_page: scope.limit_value, remote: false

        paginator = paginator_class.new (template || self), options
        paginator.to_s
      end
    end

    module HelperMethods #:nodoc:
      include UrlHelper
      include TagHelper
      include ViewHeler
      include PaginationHelper

      def self.included(*)
        super

        warn "The Kaminari::Helpers::HelperMethods is deprecated. Please use the Kaminari::Helpers module instead."
      end
    end

    include ViewHeler
    include UrlHelper
    include TagHelper
    include PaginationHelper
  end
end
