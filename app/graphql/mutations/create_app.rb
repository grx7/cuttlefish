# frozen_string_literal: true

module Mutations
  class CreateApp < Mutations::Base
    argument :attributes, Types::AppAttributes, required: true

    field :app, Types::App, null: true
    field :errors, [Types::UserError], null: false

    def resolve(attributes:)
      # Handle default values
      open_tracking_enabled = attributes.open_tracking_enabled
      open_tracking_enabled = true if open_tracking_enabled.nil?
      click_tracking_enabled = attributes.click_tracking_enabled
      click_tracking_enabled = true if click_tracking_enabled.nil?

      create_app = AppServices::Create.call(
        current_admin: context[:current_admin],
        name: attributes.name,
        open_tracking_enabled: open_tracking_enabled,
        click_tracking_enabled: click_tracking_enabled,
        custom_tracking_domain: attributes.custom_tracking_domain,
        from_domain: attributes.from_domain
      )
      if create_app.success?
        { app: create_app.result, errors: [] }
      else
        user_errors = if create_app.result
                        user_errors_from_form_errors(
                          create_app.result.errors,
                          ["attributes"]
                        )
                      else
                        [{
                          path: [],
                          message: create_app.error.message,
                          type: create_app.error.type.to_s.upcase
                        }]
                      end
        { app: nil, errors: user_errors }
      end
    end
  end
end
