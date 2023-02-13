# frozen_string_literal: true

module PrometheusExporter::Server
  class HardwareCollector < PrometheusExporter::Server::TypeCollector
    def initialize
      @cpu_usage = PrometheusExporter::Metric::Gauge.new('cpu_usage', 'cpu usage percent')
      @memory_usage = PrometheusExporter::Metric::Gauge.new('memory_usage', 'memory usage bytes')
    end

    def type
      'hardware'
    end

    def collect(_obj)
      @cpu_usage.observe(`grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'`.to_f)
      @memory_usage.observe(`ps x -o rss #{Process.pid} | tail -1`.strip.to_i)
    end

    def metrics
      [@cpu_usage, @memory_usage]
    end
  end
end
