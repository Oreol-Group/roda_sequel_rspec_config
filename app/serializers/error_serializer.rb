# frozen_string_literal: true

module ErrorSerializer
  extend self

  def from_messages(error_messages, meta: {})
    error_messages = Array(error_messages)
    { errors: build_errors(error_messages, meta) }
  end
  alias from_message from_messages

  def from_model(model)
    { errors: build_model_errors(model.errors) }
  end

  def from_hash(message)
    { errors: build_hash_error(message) }
  end

  private

  def build_hash_error(message)
    message.to_a.each_with_object([]) do |item, res|
      error = { detail: item[1] }
      error[:source] = { pointer: "/data/attributes/#{item[0]}" }
      res << error
    end
  end

  def build_errors(error_messages, meta)
    error_messages.map { |message| build_error(message, meta) }
  end

  def build_model_errors(errors)
    errors.map do |key, messages|
      messages.map do |message|
        error = build_error(message)
        error[:source] = { pointer: "/data/attributes/#{key}" }
        error
      end
    end.flatten
  end

  def build_error(message, meta = {})
    error = { detail: message }
    error[:source] = meta unless meta.empty?
    error
  end
end
