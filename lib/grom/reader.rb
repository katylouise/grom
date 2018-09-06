module Grom
  # Reads n-triple data and passes it to a Grom::Builder instance to create objects
  #
  # @since 0.1.0
  # @attr_reader [String] data n-triple data.
  # @attr_reader [Hash] statements_by_subject statements grouped by subject.
  # @attr_reader [Hash] edges_by_subject subjects connected to objects which are uris via their predicates.
  # @attr_reader [Array] objects Grom::Node objects generated from n-triple data.
  class Reader
    attr_reader :data, :statements_by_subject, :edges_by_subject, :objects

    # @param [String] data n-triple data.
    # @param [Module] decorators decorators to use when building Grom::Node objects.
    def initialize(data, decorators = nil)
      @data = data

      read_data

      @objects = Grom::Builder.new(self, decorators).objects
    end

    # Reads the n-triple data and separates the statements by subject.
    #
    # @return [Grom::Reader] an instance of self.
    def read_data
      @statements_by_subject = {}

      @edges_by_subject = {}

      RDF::NTriples::Reader.new(@data) do |reader|
        reader.each_statement do |statement|
          subject = statement.subject.to_s

          Grom::Helper.lazy_array_insert(@statements_by_subject, subject, statement)

          predicate = statement.predicate.to_s

          object_is_possible_link = statement.object.uri? || statement.object.is_a?(RDF::Node)
          predicate_is_not_a_type_definition = predicate != RDF.type.to_s

          if object_is_possible_link && predicate_is_not_a_type_definition
            predicate = Grom::Helper.get_id(predicate)
            @edges_by_subject[subject] ||= {}
            @edges_by_subject[subject][predicate] ||= []
            @edges_by_subject[subject][predicate] << statement.object.to_s
          end
        end
      end

      self
    end
  end
end
