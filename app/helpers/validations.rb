# frozen_string_literal: true

module Validations
  # class InvalidParams < StandardError; end

  def validate_with!(validation)
    validate_with(validation)
    # https://www.rubydoc.info/gems/roda/Roda/RodaPlugins/TypecastParams
    #  the 2-nd Dry::Validation's catch
    # raise Roda::RodaPlugins::TypecastParams::Error if result.failure?
  end

  def validate_with(validation)
    contract = validation.new
    # https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/TypecastParams.html
    contract.call(request.params)
  end
end
