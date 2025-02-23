class PaymentProviderNotificationService
  BASE_URL = ENV['PAYMENT_PROVIDER_URL'] || 'https://payment-provider.com/api/v1'

  def initialize(subscription)
    @subscription = subscription
  end

  # Sends POST to payment provider with the effective price, i.e. unit price with discount applied
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

  # This is to allow syntactic sugar `PaymentProviderNotificationService.(subscription)` just because I like it :P
  def self.call(*args, &block)
    new(*args, &block).update_subscription_price
  end
end
