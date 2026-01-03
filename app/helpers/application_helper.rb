module ApplicationHelper
  def safe_external_url(raw_url)
    return if raw_url.blank?

    uri = URI.parse(raw_url.to_s)
    return unless uri.is_a?(URI::HTTP) && uri.host.present?

    uri.to_s
  rescue URI::InvalidURIError
    nil
  end
end
