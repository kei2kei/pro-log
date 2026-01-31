class AutocompleteController < ApplicationController
  def tags
    query = params[:q].to_s.strip
    tags = if query.blank?
      Tag.order(:name).limit(30).pluck(:name)
    else
      Tag.where("name ILIKE ?", "%#{query}%").order(:name).limit(30).pluck(:name)
    end

    render json: tags
  end

  def search
    query = params[:q].to_s.strip
    return render json: [] if query.blank?

    pattern = "%#{query}%"
    sql = <<~SQL.squish
      (SELECT name AS value FROM products WHERE name ILIKE :pattern LIMIT 10)
      UNION
      (SELECT brand AS value FROM products WHERE brand ILIKE :pattern LIMIT 10)
      UNION
      (SELECT flavor AS value FROM products WHERE flavor ILIKE :pattern LIMIT 10)
      UNION
      (SELECT name AS value FROM tags WHERE name ILIKE :pattern LIMIT 10)
      LIMIT 20
    SQL

    results = ActiveRecord::Base.connection.exec_query(
      ActiveRecord::Base.send(:sanitize_sql_array, [ sql, { pattern: pattern } ])
    )

    render json: results.rows.flatten
  end
end
