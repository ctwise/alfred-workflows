# Extracted from https://github.com/caseyhoward/nokogiri-plist
class Parser

    class << self

      def parse(xml, options={})
        @converters = {
          'integer' => Proc.new { |node| node.content.to_i },
          'real'    => Proc.new { |node| node.content.to_f },
          'string'  => Proc.new { |node| node.content.to_s },
          'date'    => Proc.new { |node| DateTime.parse(node.content) },
          'true'    => Proc.new { |node| true },
          'false'   => Proc.new { |node| false },
          'dict'    => Proc.new { |node| parse_dict node },
          'array'   => Proc.new { |node| parse_array node },
          'data'    => Proc.new { |node| node.content.to_s }
        }.merge(options[:converters] || {})
        @dict_class = options[:dict_class] || Hash
        plist = xml.root
        plist = plist.children.first if plist.name == "plist"
        parse_value_node next_valid_sibling plist
      end

      def parse_value_node(value_node)
        @converters[value_node.name].call(value_node)
      end

      def valid_type?(type)
        @converters.has_key? type
      end

      def valid_node?(node)
        valid_type?(node.name) or node.name == "key"
      end

      def parse_dict(node)
        node.xpath('./key').inject(@dict_class.new) do |return_value, key_node|
          return_value[key_node.content] = parse_value_node(next_valid_sibling key_node)
          return_value
        end
      end

      def parse_array(node)
        node.children.inject([]) do |return_value, node|
          return_value << parse_value_node(node) if valid_node? node
          return_value
        end
      end

      def next_valid_sibling(node)
        until node.nil? or valid_type? node.name
          node = node.next_sibling
        end
        node
      end

    end

  end
