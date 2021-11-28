require 'denormalize_fields/association_extension'
require 'denormalize_fields/version'

module DenormalizeFields
  module_function

  def denormalize(fields:, from:, onto:, prefix: nil, **options)
    mapping = cast_to_mapping(fields, prefix: prefix)
    validate_options(**options)

    from.after_save do
      DenormalizeFields.call(
        record:        self,
        relation_name: onto,
        mapping:       mapping,
        **options,
      )
    end
  end

  def validate_options(**options)
    validate_conditional(options[:if])
    validate_conditional(options[:unless])
    unsupported = (options.keys - %i[if unless]).empty? ||
      raise(ArgumentError, "unsupported denormalize options: #{unsupported}")
  end

  CONDITIONAL_CLASSES = [NilClass, TrueClass, FalseClass, Symbol, Proc]

  def validate_conditional(arg)
    CONDITIONAL_CLASSES.include?(arg.class) || raise(
      ArgumentError,
      "`if:` option must be a #{CONDITIONAL_CLASSES.join('/')}, got: #{arg.class}"
    )
  end

  def cast_to_mapping(fields, prefix: nil)
    if fields.is_a?(Hash)
      prefix && raise(ArgumentError, 'pass EITHER a fields Hash OR a prefix')
      fields
    else
      Array(fields).map { |e| [e.to_sym, [prefix, e].join.to_sym] }.to_h
    end
  end

  def call(record:, relation_name:, mapping:, **options)
    return unless conditional_passes?(options[:if],     record, false)
    return unless conditional_passes?(options[:unless], record, true)

    changeset = DenormalizeFields.changeset(record: record, mapping: mapping)
    return if changeset.empty?

    Array(record.send(relation_name)).each do |related_record|
      DenormalizeFields.apply(
        changeset, to: related_record, owner: record, mapping: mapping
      )
    end
  end

  def conditional_passes?(conditional, record, inverted)
    return true if conditional.nil?

    result =
      if conditional.respond_to?(:call)
        record.instance_exec(&conditional)
      elsif conditional.class == Symbol
        record.send(conditional)
      else # true, false
        conditional
      end

    inverted ? !result : !!result
  end

  def changeset(record:, mapping:)
    mapping.each.with_object({}) do |(source, dest), hash|
      if source.is_a?(Array)
        if source.any? { |field| record.saved_change_to_attribute?(field) }
          current_values = record.attributes.values_at(*source.map(&:to_s))
          hash[dest] = current_values.join(' ')
        end
      elsif change = record.saved_change_to_attribute(source)
        hash[dest] = change.last
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
        to_record.errors.add(field, details[:error], **details.except(:error))
      end
    end
  end
end
