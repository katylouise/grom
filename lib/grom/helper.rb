module Grom
  # Namespace for helper methods.
  module Helper
    # Creates a symbol in instance variable format which has been underscored, pluralized and downcased.
    #
    # @param [String] string instance variable name.
    #
    # @example Create a pluralized instance variable symbol
    #   Grom::Helper.pluralize_instance_variable_symbol('sittingHasPerson') #=> :@sitting_has_people
    #
    # @return [Symbol] instance variable name as a symbol.
    def self.pluralize_instance_variable_symbol(string)
      string = ActiveSupport::Inflector.underscore(string)
      string = ActiveSupport::Inflector.pluralize(string).downcase

      "@#{string}".to_sym
    end

    # Creates or inserts an array and values into a hash.
    #
    # @param [Hash] hash
    # @param [String, Symbol] key the key to use in the hash.
    # @param [Object] value the value to attribute to the key.
    #
    # @example Adding values to an existing array within the hash
    #   Grom::Helper.lazy_array_insert({ :numbers => [1, 2, 3] }, :numbers, 4) #=> [1, 2, 3, 4]
    #
    # @example Adding values to a hash with no existing array
    #   Grom::Helper.lazy_array_insert({}, :numbers, 4) #=> [4]
    #
    # @return [Array] array with values inserted
    def self.lazy_array_insert(hash, key, value)
      hash[key] ||= []
      hash[key] << value
    end

    # Returns the last part of a URI
    #
    # @param [String] uri URI
    # @return [String] the last part of the URI or 'type' if the URI is an RDF type URI
    # @return [nil] if the URI is not valid
    def self.get_id(uri)
      return nil if uri.to_s['/'].nil?

      if uri == RDF::RDFS.label.to_s
        return 'label'
      elsif uri == RDF::Vocab::SKOS.prefLabel.to_s
        return 'prefLabel'
      elsif uri == RDF.type.to_s
        return 'type'
      else
        uri_object = RDF::URI(uri)

        return uri_object.fragment ? uri_object.fragment : uri_object.path.split('/').last
      end
    end
  end
end
