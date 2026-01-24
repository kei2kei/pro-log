module Recommendations
  class ProductRecommender
    AXES = %i[sweetness richness aftertaste flavor_score solubility foam].freeze
    MIN_SIGMA = 0.6

    def initialize(user)
      @user = user
    end

    def recommend(limit: 3, min_reviews: 3)
      return fallback_products(limit) unless @user

      reviews = @user.reviews.select(:overall_score, *AXES)
      return fallback_products(limit) if reviews.empty?

      weights = reviews.map { |review| weight(review.overall_score) }
      sum_w = weights.sum
      return fallback_products(limit) if sum_w.zero?

      mu = AXES.index_with { |axis| weighted_sum(reviews, weights, axis) / sum_w }
      sigma = AXES.index_with do |axis|
        variance = reviews.each_with_index.sum do |review, index|
          weights[index] * ((review.public_send(axis).to_f - mu[axis])**2)
        end
        [Math.sqrt(variance / sum_w), MIN_SIGMA].max
      end

      user_conf = AXES.sum { |axis| 1.0 / (1.0 + sigma[axis]) } / AXES.length
      count_bonus = [1.0, reviews.size / 8.0].min
      user_conf_final = 0.3 + 0.7 * user_conf * count_bonus

      candidates = Product.includes(:product_stat)
        .joins(:product_stat)
        .where("product_stats.reviews_count >= ?", min_reviews)

      scored = candidates.filter_map do |product|
        stats = product.product_stat
        next unless stats

        axis_scores = AXES.map do |axis|
          avg_value = stats.public_send("avg_#{axis}")
          next if avg_value.nil?

          Math.exp(-((avg_value - mu[axis])**2) / (2.0 * (sigma[axis]**2)))
        end
        next if axis_scores.any?(&:nil?)

        sim = axis_scores.sum / AXES.length
        product_bonus = [1.0, stats.reviews_count.to_f / 10.0].min
        score = sim * user_conf_final * product_bonus
        { product: product, score: score }
      end

      return fallback_products(limit) if scored.empty?

      scored.sort_by { |entry| -entry[:score] }
        .first(limit)
        .map { |entry| entry[:product] }
    end

    private

    def weight(overall_score)
      0.2 + 0.8 * ((overall_score.to_f - 1.0) / 4.0)
    end

    def weighted_sum(reviews, weights, axis)
      reviews.each_with_index.sum do |review, index|
        weights[index] * review.public_send(axis).to_f
      end
    end

    def fallback_products(limit)
      Product.includes(:product_stat)
        .left_joins(:product_stat)
        .order(Arel.sql("COALESCE(product_stats.reviews_count, 0) DESC, products.created_at DESC"))
        .limit(limit)
    end
  end
end
