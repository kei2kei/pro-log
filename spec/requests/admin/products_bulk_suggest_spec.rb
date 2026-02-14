require "rails_helper"

RSpec.describe "Admin::Products bulk_suggest", type: :request do
  let(:path) { bulk_suggest_admin_products_path }

  def bulk_params
    {
      bulk: {
        row_count: "5",
        name: "MyProtein",
        brand: "Brand",
        protein_type: "whey",
        default_price: "3990",
        default_image_url: "https://example.com/image.jpg",
        default_reference_url: "https://example.com/item",
        items: {
          "0" => {
            flavor: "",
            price: "",
            calorie: "",
            protein: "",
            fat: "",
            carbohydrate: "",
            image_url: "",
            reference_url: ""
          }
        }
      }
    }
  end

  it "未ログインはログイン画面へリダイレクト" do
    post path, params: bulk_params

    expect(response).to redirect_to(new_user_session_path)
  end

  it "一般ユーザーは権限エラーでリダイレクト" do
    user = create(:user, admin: false)
    sign_in user

    post path, params: bulk_params

    expect(response).to redirect_to(root_path)
  end

  it "admin + JSON: 成功時は補完行を返す" do
    admin = create(:user, admin: true)
    sign_in admin

    service = instance_double(Admin::NutritionSuggestionService, call: {
      ok: true,
      rows: [
        {
          flavor: "チョコレート",
          calorie: "103",
          protein: "21",
          fat: "1.9",
          carbohydrate: "1"
        }
      ]
    })

    allow(Admin::NutritionSuggestionService).to receive(:new).and_return(service)

    post path, params: bulk_params, as: :json

    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)
    expect(body["ok"]).to eq(true)
    expect(body["rows"]).to be_an(Array)
    expect(body["rows"].size).to be >= 5
    expect(body["rows"].first["flavor"]).to eq("チョコレート")
  end

  it "admin + JSON: 失敗時は422でエラーを返す" do
    admin = create(:user, admin: true)
    sign_in admin

    service = instance_double(Admin::NutritionSuggestionService, call: {
      ok: false,
      error: "フレーバー情報を抽出できませんでした。"
    })
    allow(Admin::NutritionSuggestionService).to receive(:new).and_return(service)

    post path, params: bulk_params, as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    body = JSON.parse(response.body)
    expect(body["ok"]).to eq(false)
    expect(body["error"]).to include("抽出できませんでした")
  end
end
