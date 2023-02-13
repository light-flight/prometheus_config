# frozen_string_literal: true

# client allows instrumentation to send info to server
require 'prometheus_exporter/server'
require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'

# custom classes from lib
require 'prometheus_exporter/server/hardware_collector'
require 'prometheus_exporter/instrumentation/hardware'

HOST = ENV.fetch('PROMETHEUS_EXPORTER_HOST', '0.0.0.0')
PORT = ENV.fetch('PROMETHEUS_EXPORTER_PORT', 9394)

server =
  begin
    PrometheusExporter::Server::WebServer.new(bind: HOST, port: PORT)
  rescue Errno::EADDRINUSE
    nil
  end
return if server.nil?

server.collector.register_collector(PrometheusExporter::Server::HardwareCollector.new) # add custom collector
server.start

# wire up a default local client
PrometheusExporter::Client.default = PrometheusExporter::LocalClient.new(collector: server.collector)

PrometheusExporter::Instrumentation::Process.start # RSS and Ruby metrics
PrometheusExporter::Instrumentation::Hardware.start # cpu and memory data

if Rails.env != 'test'
  require 'prometheus_exporter/middleware'

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift(PrometheusExporter::Middleware)
end
