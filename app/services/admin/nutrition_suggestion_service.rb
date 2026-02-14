require "net/http"
require "json"
require "zlib"
require "stringio"

module Admin
  class NutritionSuggestionService
    API_URL = URI("https://api.openai.com/v1/responses")
    PAGE_FETCH_OPEN_TIMEOUT = 15
    PAGE_FETCH_READ_TIMEOUT = 20
    PAGE_FETCH_RETRY_COUNT = 1

    def initialize(reference_url:)
      @reference_url = reference_url.to_s.strip
      @api_key = openai_api_key
    end

    def call
      Rails.logger.info("[NutritionSuggestionService] start reference_url=#{@reference_url}")
      return failure("参照URLを入力してください。") if @reference_url.blank?
      return failure("OPENAI_API_KEY が未設定です。") if @api_key.blank?
      return failure("参照URLが不正です。") unless valid_http_url?(@reference_url)

      page_result = fetch_page_data(@reference_url)
      return failure(page_result[:error]) unless page_result[:ok]
      page_text = page_result[:text]
      flavor_candidates = Array(page_result[:flavors]).map(&:to_s).map(&:strip).reject(&:blank?).uniq
      Rails.logger.info("[NutritionSuggestionService] fetched_page_text length=#{page_text.to_s.length} flavor_candidates=#{flavor_candidates.size}")

      response = Net::HTTP.start(API_URL.host, API_URL.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(API_URL)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request.body = request_body(page_text).to_json
        http.request(request)
      end
      Rails.logger.info("[NutritionSuggestionService] openai_status=#{response.code}")

      unless response.is_a?(Net::HTTPSuccess)
        return failure("AIの呼び出しに失敗しました。(#{response.code}) #{openai_error_message(response)}")
      end

      parsed = JSON.parse(response.body)
      content = extract_json_content(parsed)
      return failure("AIレスポンスを解析できませんでした。") if content.blank?

      data = parse_ai_json(content)
      flavors = rows_from_ai_data(data)
      Rails.logger.info("[NutritionSuggestionService] rows_from_ai_data=#{flavors.size}")
      flavors = rows_from_page_text(page_text) if flavors.blank?
      Rails.logger.info("[NutritionSuggestionService] rows_after_fallback=#{flavors.size}")
      flavors = merge_with_flavor_candidates(flavors, flavor_candidates)
      default_nutrition = extract_default_nutrition(page_text)
      Rails.logger.info("[NutritionSuggestionService] defaults=#{default_nutrition.inspect}")
      flavors = apply_default_nutrition(flavors, default_nutrition)
      Rails.logger.info("[NutritionSuggestionService] rows_after_merge=#{flavors.size}")

      return failure("フレーバー情報を抽出できませんでした。") if flavors.blank?

      Rails.logger.info("[NutritionSuggestionService] success rows=#{flavors.size}")
      success(flavors)
    rescue JSON::ParserError
      Rails.logger.warn("[NutritionSuggestionService] json_parse_error")
      failure("AIレスポンスのJSON解析に失敗しました。")
    rescue StandardError => e
      Rails.logger.error("[NutritionSuggestionService] error=#{e.class} message=#{e.message}")
      failure("AI補完でエラーが発生しました: #{e.message}")
    end

    private

    def request_body(page_text)
      {
        model: "gpt-4.1-mini",
        input: [
          {
            role: "system",
            content: [
              {
                type: "input_text",
                text: "You extract product nutrition facts from a product page URL. Return strict JSON only."
              }
            ]
          },
          {
            role: "user",
            content: [
              {
                type: "input_text",
                text: user_prompt(page_text)
              }
            ]
          }
        ]
      }
    end

    def openai_error_message(response)
      body = response.body.to_s
      return "" if body.blank?

      parsed = JSON.parse(body)
      message = parsed.dig("error", "message").to_s
      message.presence || ""
    rescue JSON::ParserError
      ""
    end

    def openai_api_key
      from_credentials =
        begin
          credentials = Rails.application.credentials
          if credentials.respond_to?(:dig)
            credentials.dig(:openai, :api_key).to_s
          elsif credentials.respond_to?(:openai)
            openai = credentials.openai
            if openai.is_a?(Hash)
              (openai[:api_key] || openai["api_key"]).to_s
            else
              ""
            end
          else
            ""
          end
        rescue StandardError
          ""
        end
      from_env = ENV["OPENAI_API_KEY"].to_s
      from_credentials.presence || from_env.presence || ""
    end

    def user_prompt(page_text)
      <<~PROMPT
        URL: #{@reference_url}
        ページ本文:
        #{page_text}

        上記URLの商品ページを読み取り、販売中フレーバーごとに栄養情報を抽出してください。
        必ず次のJSON形式のみを返してください（前後に説明不要）:
        {
          "flavors": [
            {
              "flavor": "チョコレート",
              "calorie": 120,
              "protein": 20.0,
              "fat": 1.0,
              "carbohydrate": 3.0
            }
          ]
        }

        ルール:
        - 不明な値は空文字 "" にする
        - 数値は可能な限り数値型で返す
        - フレーバー名は重複させない
      PROMPT
    end

    def valid_http_url?(value)
      uri = URI.parse(normalize_url(value))
      uri.is_a?(URI::HTTP) && uri.host.present?
    rescue URI::InvalidURIError
      false
    end

    def fetch_page_data(url, limit: 40_000)
      html_result = fetch_html(url)
      return html_result unless html_result[:ok]

      html = html_result[:html]
      app_data = extract_item_page_app_data(html)
      app_data_text = app_data[:text]
      app_data_flavors = Array(app_data[:flavors])

      text = html
        .gsub(/<script.*?<\/script>/m, " ")
        .gsub(/<style.*?<\/style>/m, " ")
        .gsub(/<[^>]+>/, " ")
        .gsub(/\s+/, " ")
        .strip
      text = [ app_data_text, text ].reject(&:blank?).join(" ")
      return failure_result("参照URLのページ本文が取得できませんでした。") if text.blank?

      success_result(text: prioritize_text(text, limit: limit), flavors: app_data_flavors)
    end

    def fetch_html(url, redirect_limit: 3)
      return failure_result("参照URLのリダイレクト回数が上限を超えました。") if redirect_limit.negative?

      normalized_url = normalize_url(url)
      uri = URI.parse(normalized_url)
      response = nil
      retries = PAGE_FETCH_RETRY_COUNT

      begin
        response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.scheme == "https",
          read_timeout: PAGE_FETCH_READ_TIMEOUT,
          open_timeout: PAGE_FETCH_OPEN_TIMEOUT
        ) do |http|
          request = Net::HTTP::Get.new(uri.request_uri)
          request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
          request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
          request["Accept-Language"] = "ja,en-US;q=0.9,en;q=0.8"
          request["Accept-Encoding"] = "gzip,deflate"
          http.request(request)
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, EOFError, SocketError, Errno::ECONNRESET, Errno::ETIMEDOUT
        if retries.positive?
          retries -= 1
          retry
        end
        return failure_result("参照URLの取得に失敗しました。ネットワークまたはURLをご確認ください。")
      end

      case response
      when Net::HTTPSuccess
        body = decode_response_body(response)
        html = normalize_html_encoding(body, response["content-type"])
        success_result(html: html)
      when Net::HTTPRedirection
        location = response["location"].to_s
        return failure_result("参照URLのリダイレクト先が不正です。") if location.blank?
        next_url = URI.join(normalized_url, location).to_s
        fetch_html(next_url, redirect_limit: redirect_limit - 1)
      else
        failure_result("参照URLの取得に失敗しました。(HTTP #{response.code})")
      end
    rescue URI::InvalidURIError
      failure_result("参照URLが不正です。")
    rescue StandardError
      failure_result("参照URLの取得に失敗しました。ネットワークまたはURLをご確認ください。")
    end

    def normalize_url(url)
      url.to_s.strip
    end

    def decode_response_body(response)
      body = response.body.to_s
      encoding = response["content-encoding"].to_s.downcase

      case encoding
      when "gzip"
        Zlib::GzipReader.new(StringIO.new(body)).read
      when "deflate"
        Zlib::Inflate.inflate(body)
      else
        body
      end
    rescue Zlib::Error
      body
    end

    def normalize_html_encoding(html, content_type_header)
      charset = content_type_header.to_s[/charset=([^;]+)/i, 1].to_s.strip.presence
      candidates = [ charset, "UTF-8", "EUC-JP", "Windows-31J", "Shift_JIS", "ISO-2022-JP" ].compact.uniq

      candidates.each do |encoding_name|
        begin
          encoded = html.dup.force_encoding(encoding_name)
          next unless encoded.valid_encoding?
          return encoded.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
        rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError, ArgumentError
          next
        end
      end

      html.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    end

    def extract_json_content(parsed)
      return parsed["output_text"] if parsed["output_text"].present?

      output = Array(parsed["output"])
      text_parts = output.flat_map do |block|
        Array(block["content"]).map { |content| content["text"] }.compact
      end
      text_parts.join("\n")
    end

    def extract_item_page_app_data(html)
      script_body = html.to_s[/<script[^>]*id=["']item-page-app-data["'][^>]*>(.*?)<\/script>/m, 1].to_s
      return { text: "", flavors: [] } if script_body.blank?

      parsed = JSON.parse(script_body)
      item = parsed.dig("api", "data", "itemInfoSku") || parsed.dig("newApi", "itemInfoSku") || {}
      title = item["title"].to_s
      description_html = item.dig("pcFields", "newProductDescription").to_s
      selectors = Array(item["variantSelectors"])
      flavor_values = selectors.flat_map { |s| Array(s["values"]).map { |v| v["label"].to_s.presence || v["value"].to_s } }.compact

      description_text = description_html
        .gsub(/<script.*?<\/script>/m, " ")
        .gsub(/<style.*?<\/style>/m, " ")
        .gsub(/<[^>]+>/, " ")
        .gsub(/\s+/, " ")
        .strip

      flavor_values = flavor_values.map(&:strip).reject(&:blank?).uniq
      flavor_line = flavor_values.present? ? "フレーバー一覧: #{flavor_values.join(', ')}" : nil
      { text: [ title, flavor_line, description_text ].compact.join(" "), flavors: flavor_values }
    rescue JSON::ParserError
      { text: "", flavors: [] }
    end

    def prioritize_text(text, limit:)
      return text if text.length <= limit

      keywords = [
        "フレーバー一覧", "フレーバー", "variantSelectors", "原材料名", "栄養成分",
        "タンパク質", "脂質", "炭水化物", "カロリー", "kcal", "protein"
      ]
      snippets = keywords.filter_map do |kw|
        idx = text.index(kw)
        next if idx.nil?
        from = [ idx - 1200, 0 ].max
        to = [ idx + 3500, text.length ].min
        text[from...to]
      end
      merged = snippets.join(" ")
      candidate = merged.presence || text
      candidate[0, limit]
    end

    def parse_ai_json(content)
      raw = content.to_s.strip
      raw = raw.gsub(/\A```(?:json)?\s*/m, "").gsub(/\s*```\z/m, "")
      JSON.parse(raw)
    end

    def rows_from_ai_data(data)
      rows =
        if data.is_a?(Array)
          data
        elsif data.is_a?(Hash)
          Array(data["flavors"]).presence ||
            Array(data["rows"]).presence ||
            Array(data["items"]).presence ||
            Array(data.dig("data", "flavors")).presence ||
            []
        else
          []
        end

      rows.map { |row| normalize_row(row) }.reject { |row| row[:flavor].blank? }
    end

    def rows_from_page_text(text)
      source = text.to_s
      flavor_names = source.scan(/([^\s:：]{2,30})[:：]\s*ホエイプロテイン/).flatten.map(&:strip).uniq
      return [] if flavor_names.blank?

      protein = source[/タンパク質[^0-9]{0,10}([0-9]+(?:\.[0-9]+)?)\s*g/i, 1]
      fat = source[/脂質[^0-9]{0,10}([0-9]+(?:\.[0-9]+)?)\s*g/i, 1]
      carbohydrate = source[/炭水化物[^0-9]{0,10}([0-9]+(?:\.[0-9]+)?)\s*g/i, 1]
      calorie = source[/([0-9]+(?:\.[0-9]+)?)\s*kcal/i, 1]

      flavor_names.map do |name|
        {
          flavor: name,
          calorie: calorie.presence,
          protein: protein.presence,
          fat: fat.presence,
          carbohydrate: carbohydrate.presence
        }
      end
    end

    def merge_with_flavor_candidates(rows, flavor_candidates)
      normalized_rows = Array(rows).map { |row| normalize_row(row) }.reject { |row| row[:flavor].blank? }
      return normalized_rows if flavor_candidates.blank?

      row_by_key = normalized_rows.index_by { |r| flavor_key(r[:flavor]) }

      merged = flavor_candidates.map do |flavor|
        matched = row_by_key[flavor_key(flavor)]
        next matched if matched.present?

        {
          flavor: flavor,
          calorie: nil,
          protein: nil,
          fat: nil,
          carbohydrate: nil
        }
      end

      merged.map { |row| normalize_row(row) }.reject { |row| row[:flavor].blank? }.uniq { |r| flavor_key(r[:flavor]) }
    end

    def extract_default_nutrition(text)
      source = text.to_s
      {
        calorie: source[/([0-9]+(?:\.[0-9]+)?)\s*kcal/i, 1].presence,
        protein: source[/タンパク質[^0-9]{0,20}([0-9]+(?:\.[0-9]+)?)\s*g/i, 1].presence,
        fat: source[/脂質[^0-9]{0,20}([0-9]+(?:\.[0-9]+)?)\s*g/i, 1].presence,
        carbohydrate: source[/炭水化物[^0-9]{0,20}([0-9]+(?:\.[0-9]+)?)\s*g/i, 1].presence
      }
    end

    def apply_default_nutrition(rows, defaults)
      return rows if rows.blank?

      rows.map do |row|
        normalized = normalize_row(row)
        {
          flavor: normalized[:flavor],
          calorie: normalized[:calorie].presence || defaults[:calorie],
          protein: normalized[:protein].presence || defaults[:protein],
          fat: normalized[:fat].presence || defaults[:fat],
          carbohydrate: normalized[:carbohydrate].presence || defaults[:carbohydrate]
        }
      end
    end

    def flavor_key(name)
      name.to_s.downcase.gsub(/[[:space:]\u3000・＆&\-_]/, "")
    end

    def normalize_row(raw)
      hash = raw.to_h.with_indifferent_access
      {
        flavor: (hash[:flavor] || hash[:flavor_name] || hash[:name] || hash[:フレーバー] || hash[:味]).to_s.strip,
        calorie: (hash[:calorie] || hash[:kcal] || hash[:カロリー]).presence,
        protein: (hash[:protein] || hash[:p] || hash[:タンパク質]).presence,
        fat: (hash[:fat] || hash[:f] || hash[:脂質]).presence,
        carbohydrate: (hash[:carbohydrate] || hash[:carbs] || hash[:c] || hash[:炭水化物]).presence
      }
    end

    def success(rows)
      { ok: true, rows: rows }
    end

    def failure(message)
      { ok: false, error: message }
    end

    def success_result(payload = {})
      { ok: true }.merge(payload)
    end

    def failure_result(message)
      { ok: false, error: message }
    end
  end
end
