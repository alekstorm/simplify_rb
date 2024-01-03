# Optimized Douglas-Peucker algorithm

module SimplifyRb
  class DouglasPeuckerSimplifier
    def process(points, sq_tolerance, sq_gap_tolerance)
      points.first.keep = true
      points.last.keep  = true

      simplify_douglas_peucker(points, sq_tolerance, sq_gap_tolerance)
        .select(&:keep)
    end

    private

    MaxSqDist = Struct.new(:max_sq_dist, :index)

    def simplify_douglas_peucker(points, sq_tolerance, sq_gap_tolerance)
      first_i = 0
      last_i  = points.length - 1
      index = nil
      stack = []

      while last_i
        result = calc_max_sq_dist(first_i, last_i, points)
        index = result.index

        keep = result.max_sq_dist > sq_tolerance
        if !keep && !index.nil? && !sq_gap_tolerance.nil?
          new_seg_dist = points[first_i].get_sq_dist_to(points[last_i])
          keep = new_seg_dist > sq_gap_tolerance
        end

        if keep
          points[index].keep = true

          stack.push(first_i, index, index, last_i)
        end

        first_i, last_i = stack.pop(2)
      end

      points
    end

    def calc_max_sq_dist(first_i, last_i, points)
      index = nil
      max_sq_dist = 0
      range = (first_i + 1)...last_i

      range.each do |i|
        sq_dist = get_sq_seg_dist(points[i], points[first_i], points[last_i])

        if sq_dist > max_sq_dist
          index = i
          max_sq_dist = sq_dist
        end
      end

      MaxSqDist.new(max_sq_dist, index)
    end

    # Square distance from a point to a segment
    def get_sq_seg_dist(point, point_1, point_2)
      x  = point_1.x
      y  = point_1.y
      dx = point_2.x - x
      dy = point_2.y - y

      if dx != 0 || dy != 0
        t = ((point.x - x) * dx + (point.y - y) * dy) / (dx * dx + dy * dy)

        if t > 1
          x = point_2.x
          y = point_2.y

        elsif t > 0
          x += dx * t
          y += dy * t
        end
      end

      dx = point.x - x
      dy = point.y - y

      dx * dx + dy * dy
    end
  end
end
