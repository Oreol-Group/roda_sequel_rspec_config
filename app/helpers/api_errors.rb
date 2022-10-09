# frozen_string_literal: true

module ApiErrors
  def error_response(error_messages, meta: {})
    case error_messages
    when Sequel::Model
      ErrorSerializer.from_model(error_messages)
    when Hash
      ErrorSerializer.from_hash(error_messages)
    else
      ErrorSerializer.from_messages(error_messages, meta: meta)
    end
  end
end
