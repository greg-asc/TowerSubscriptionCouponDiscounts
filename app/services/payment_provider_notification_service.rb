class PaymentProviderNotificationService
  BASE_URL = ENV['PAYMENT_PROVIDER_URL'] || 'https://payment-provider.com'

  def initialize(subscription)
    @subscription = subscription
  end

  def update_subscription_price
    url  = "#{BASE_URL}/subscriptions/#{@subscription.external_id}"
    body = { unit_price: @subscription.effective_price }

    response = HTTParty.post(
      url,
      body: body.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    return response.success?
  end

  def self.call(*args, &block)
    new(*args, &block).update_subscription_price
  end
end
