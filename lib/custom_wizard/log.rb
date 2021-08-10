# frozen_string_literal: true
class CustomWizard::Log
  include ActiveModel::Serialization

  attr_accessor :date, :wizard, :action, :user, :message

  PAGE_LIMIT = 100

  def initialize(attrs)
    @date = attrs['date']
    @wizard = attrs['wizard']
    @action = attrs['action']
    @user = attrs['user']
    @message = attrs['message']
  end

  def self.create(wizard, action, user, message)
    log_id = SecureRandom.hex(12)

    PluginStore.set('custom_wizard_log',
      log_id.to_s,
      {
        date: Time.now,
        wizard: wizard,
        action: action,
        user: user,
        message: message
      }
    )
  end

  def self.list_query
    PluginStoreRow.where("
      plugin_name = 'custom_wizard_log' AND
      (value::json->'date') IS NOT NULL
    ").order("value::json->>'date' DESC")
  end

  def self.list(page = 0, limit = nil)
    limit = limit.to_i > 0 ? limit.to_i : PAGE_LIMIT
    page = page.to_i

    self.list_query.limit(limit)
      .offset(page * limit)
      .map { |r| self.new(JSON.parse(r.value)) }
  end
end
