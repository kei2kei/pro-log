require "rails_helper"

RSpec.describe "商品一覧の検索", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user, scope: :user
  end

  it "フリーワードは複数語をAND条件で絞り込める" do
    product = create(:product, name: "Belegend", flavor: "ストロベリー")
    create(:product, name: "Belegend", flavor: "チョコ")
    create(:product, name: "Other", flavor: "ストロベリー")

    get products_path, params: { q: { name_or_brand_or_flavor_or_tags_name_cont: "Belegend,ストロベリー" } }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(product.name)
    expect(response.body).to include("ストロベリー")
    expect(response.body).not_to include("チョコ")
  end

  it "タグ名もフリーワード検索の対象になる" do
    product = create(:product, name: "Alpha")
    tag = create(:tag, name: "DNS")
    create(:product_tagging, product: product, tag: tag)

    get products_path, params: { q: { name_or_brand_or_flavor_or_tags_name_cont: "DNS" } }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(product.name)
  end

  it "詳細検索は6軸の範囲で絞り込める" do
    in_range = create(:product, name: "InRange")
    out_range = create(:product, name: "OutRange")
    create(:product_stat, product: in_range, avg_sweetness: 3.0)
    create(:product_stat, product: out_range, avg_sweetness: 5.0)

    get products_path, params: { q: { product_stat_avg_sweetness_gteq: 2, product_stat_avg_sweetness_lteq: 4 } }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("InRange")
    expect(response.body).not_to include("OutRange")
  end

  it "価格帯で絞り込める" do
    in_range = create(:product, name: "PriceIn", price: 3000)
    create(:product, name: "PriceOut", price: 8000)

    get products_path, params: { q: { price_gteq: 2000, price_lteq: 5000 } }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("PriceIn")
    expect(response.body).not_to include("PriceOut")
  end

  it "プロテインの種類で絞り込める" do
    whey = create(:product, name: "WheyOnly", protein_type: :whey)
    create(:product, name: "SoyOnly", protein_type: :soy)

    get products_path, params: { q: { protein_type_eq: Product.protein_types[:whey] } }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(whey.name)
    expect(response.body).not_to include("SoyOnly")
  end

  it "満足度(平均)で絞り込める" do
    high = create(:product, name: "HighScore")
    low = create(:product, name: "LowScore")
    create(:product_stat, product: high, avg_overall_score: 4.2)
    create(:product_stat, product: low, avg_overall_score: 2.1)

    get products_path, params: { q: { product_stat_avg_overall_score_gteq: 4 } }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("HighScore")
    expect(response.body).not_to include("LowScore")
  end

  it "フリーワードと種類の複合条件で絞り込める" do
    match = create(:product, name: "Alpha Whey", protein_type: :whey)
    create(:product, name: "Alpha Soy", protein_type: :soy)

    get products_path, params: {
      q: {
        name_or_brand_or_flavor_or_tags_name_cont: "Alpha",
        protein_type_eq: Product.protein_types[:whey]
      }
    }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Alpha Whey")
    expect(response.body).not_to include("Alpha Soy")
  end
end
