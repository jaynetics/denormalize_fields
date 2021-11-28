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
        from: association.active_record,
        onto: association.name,
        **options,
      )
    end
  end
end

ActiveRecord::Associations::Builder::Association.extensions <<
  DenormalizeFields::AssociationExtension
