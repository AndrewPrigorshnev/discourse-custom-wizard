# frozen_string_literal: true
class CustomWizard::AdminController < ::Admin::AdminController
  before_action :ensure_admin

  def index
    render_json_dump(
      #TODO replace with appropriate static?
      api_section: ["business"].include?(CustomWizard::Subscription.type),
      active_notice_count: CustomWizard::Notice.active_count,
      featured_notices: ActiveModel::ArraySerializer.new(
        CustomWizard::Notice.list(
          type: CustomWizard::Notice.types[:info],
          archetype: CustomWizard::Notice.archetypes[:subscription_message]
        ),
        each_serializer: CustomWizard::NoticeSerializer
      )
    )
  end

  private

  def find_wizard
    params.require(:wizard_id)
    @wizard = CustomWizard::Wizard.create(params[:wizard_id].underscore)
    raise Discourse::InvalidParameters.new(:wizard_id) unless @wizard
  end

  def custom_field_list
    serialize_data(CustomWizard::CustomField.full_list, CustomWizard::CustomFieldSerializer)
  end

  def render_error(message)
    render json: failed_json.merge(error: message)
  end
end
