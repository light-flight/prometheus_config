# frozen_string_literal: true

module PrometheusExporter::Instrumentation
  class Hardware < PeriodicStats
    FREQUENCY = ENV.fetch('PROMETHEUS_DATA_UPDATE_INTERVAL', 2).to_i

    def self.start(client: nil, frequency: FREQUENCY)
      client ||= PrometheusExporter::Client.default

      worker_loop do
        client.send_json(type: 'hardware')
      end

      super
    end
  end
end
