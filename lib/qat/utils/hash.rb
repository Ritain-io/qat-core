require 'active_support/core_ext/hash/keys'

module QAT
  # This is a wrapper namespace for utility methods in QAT
  module Utils
    # This module gives helper methods for Hash
    module Hash
      # Returns values form a given path (keys) of a complex structure of data
      # @param node [Object] the node of the structure to look into (root or leaf)
      # @param path [Array] list of keys to use for searching values
      # @possible_leaf_nodes [Array] possible values for return (optional)
      # @return [Array]
      def navigate_path(node, path, possible_leaf_nodes = [])

        node = node.dup.symbolize_keys if node.kind_of?(::Hash)

        if path.empty?
          possible_leaf_nodes << node
          return possible_leaf_nodes
        end

        path      = path.dup
        path_head = path.shift
        regex     = '.*\[(\*|-?\d+)\]'

        obj_index = nil
        match     = path_head.to_s.match(regex)
        if match
          index     = match.begin(1)
          obj_index = match[1]
          path_head = path_head.slice(0, index - 1).to_sym
        end

        if !node || (!node.kind_of?(Array) && !node.keys.map(&:to_sym).include?(path_head.to_sym))
          possible_leaf_nodes << :field_not_found
          return possible_leaf_nodes
        end

        new_node = nil
        if node.kind_of?(Array) && obj_index #index is prefixed
          if obj_index.eql? '*'
            node.each do |item|
              navigate_path(item, path, possible_leaf_nodes)
            end
            possible_leaf_nodes
          else
            new_node = node[obj_index.to_i]
          end

        else
          new_node = node[path_head.to_sym]
        end


        if new_node.kind_of?(Array) && obj_index #index is suffixed
          if obj_index.eql? '*'
            new_node.each do |item|
              navigate_path(item, path, possible_leaf_nodes)
            end
            possible_leaf_nodes
          else
            new_node = new_node[obj_index.to_i]
            navigate_path(new_node, path, possible_leaf_nodes)
          end
        else
          navigate_path(new_node, path, possible_leaf_nodes)
        end
      end

      module_function :navigate_path
    end
  end
end
