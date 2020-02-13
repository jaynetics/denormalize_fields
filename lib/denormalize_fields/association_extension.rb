require 'active_record'

module DenormalizeFields
  module AssociationExtension
    OPTION = :denormalize

    def self.valid_options
      [OPTION]
    end

    def self.build(model, association)
      return unless options = association.options[OPTION]

      DenormalizeFields.denormalize(
        fields: options[:fields],
        from:   association.active_record,
        onto:   association.name,
        prefix: options[:prefix],
      )
    end
  end
end

ActiveRecord::Associations::Builder::Association.extensions <<
  DenormalizeFields::AssociationExtension
