# frozen_string_literal: true

module SolidusEasypost
  class Configuration
    attr_accessor :purchase_labels
    attr_writer :shipping_rate_calculator_class, :shipping_method_selector_class

    def initialize
      self.purchase_labels = true
    end

    def shipping_rate_calculator_class
      @shipping_rate_calculator_class ||= 'SolidusEasypost::ShippingRateCalculator'
      @shipping_rate_calculator_class.constantize
    end

    def shipping_method_selector_class
      @shipping_method_selector_class ||= 'SolidusEasypost::ShippingMethodSelector'
      @shipping_method_selector_class.constantize
    end
  end
end
