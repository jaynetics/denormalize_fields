require 'denormalize_fields/association_extension'
require 'denormalize_fields/version'

module DenormalizeFields
  module_function

  def denormalize(fields:, from:, onto:, prefix: nil)
    mapping = cast_to_mapping(fields, prefix: prefix)

    from.after_save do
      DenormalizeFields.call(record: self, relation_name: onto, mapping: mapping)
    end
  end

  def cast_to_mapping(fields, prefix: nil)
    if fields.is_a?(Hash)
      prefix && raise(ArgumentError, 'pass EITHER a fields Hash OR a prefix')
      fields
    else
      Array(fields).map { |e| [e.to_sym, [prefix, e].join.to_sym] }.to_h
    end
  end

  def call(record:, relation_name:, mapping:)
    changeset = DenormalizeFields.changeset(record: record, mapping: mapping)
    return if changeset.empty?

    Array(record.send(relation_name)).each do |related_record|
      DenormalizeFields.apply(
        changeset, to: related_record, owner: record, mapping: mapping
      )
    end
  end

  def changeset(record:, mapping:)
    keys = mapping.keys.flatten
    record.saved_changes.slice(*keys).each.with_object({}) do |(k, v), acc|
      changed_field = k.to_sym
      new_value = v.last

      mapping.each do |source, dest|
        if source.is_a?(Array) && source.include?(changed_field)
          if acc.key?(dest)
            acc[dest] += " #{new_value}"
          else
            acc[dest] = new_value.to_s
          end
        elsif source == changed_field
          acc[dest] = new_value
        end
      end
    end
  end

  # Note: missing related records are ignored, and new related records are not
  # persisted. Extra options to raise/create/persist in this case might be nice.
  def apply(changeset, to:, owner:, mapping:)
    return if to.nil?

    to.assign_attributes(changeset)
    return if to.new_record? ? to.valid? : to.save

    DenormalizeFields.copy_errors(to.errors, to_record: owner, mapping: mapping)
    raise(ActiveRecord::RecordInvalid, to)
  end

  # TODO: use Errors#import when it becomes available in rails 6.1 or 6.2
  def copy_errors(errors, to_record:, mapping:)
    errors.details.each do |key, array|
      field = mapping.rassoc(key.to_sym).first
      array.each do |details|
        to_record.errors.add(field, details[:error], details.except(:error))
      end
    end
  end
end
