require 'simplify_rb/version'
require 'simplify_rb/point'
require 'simplify_rb/radial_distance_simplifier'
require 'simplify_rb/douglas_peucker_simplifier'

module SimplifyRb
  class Simplifier
    def process(raw_points, tolerance = 1, highest_quality = false, gap_tolerance = nil)
      raise ArgumentError.new('raw_points must be enumerable') unless raw_points.is_a? Enumerable

      return raw_points if raw_points.length <= 1

      sq_tolerance = tolerance ** 2
      sq_gap_tolerance = gap_tolerance ** 2 unless gap_tolerance.nil?

      points = raw_points.map { |p| Point.new(p) }

      unless highest_quality
        points = RadialDistanceSimplifier.new.process(points, sq_tolerance)
      end

      DouglasPeuckerSimplifier.new
        .process(points, sq_tolerance, sq_gap_tolerance)
        .map(&:original_entity)
    end
  end
end
