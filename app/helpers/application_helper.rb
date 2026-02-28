module ApplicationHelper
  def safe_external_url(raw_url)
    return if raw_url.blank?

    uri = URI.parse(raw_url.to_s)
    return unless uri.is_a?(URI::HTTP) && uri.host.present?

    uri.to_s
  rescue URI::InvalidURIError
    nil
  end

  def axis_label(axis, value)
    labels = I18n.t("axis_labels.#{axis}", default: [])
    return "" if labels.blank? || value.blank?
    index = [ [ value.to_i, 1 ].max, 5 ].min - 1
    labels[index]
  end

  def axis_label_for_avg(axis, avg_value)
    return "" if avg_value.blank?
    axis_label(axis, avg_value.round)
  end

  def highlight_mentions(text)
    escaped = ERB::Util.html_escape(text.to_s)
    highlighted = escaped.gsub(/(^|[[:space:]])@([^\s@]+)/u) do
      %(#{$1}<span class="font-semibold text-brand">@#{$2}</span>)
    end
    highlighted.html_safe
  end
end
