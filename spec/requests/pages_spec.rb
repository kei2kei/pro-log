require "rails_helper"

RSpec.describe "お問い合わせ", type: :request do
  describe "GET /contact" do
    it "お問い合わせページを表示できる" do
      get contact_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /contact" do
    let(:valid_params) do
      {
        contact_form: {
          name: "テストユーザー",
          email: "test@example.com",
          subject: "テスト件名",
          message: "テスト本文",
          website: ""
        }
      }
    end

    it "正常に送信できる(リキャプチャOK)" do
      allow_any_instance_of(PagesController).to receive(:verify_recaptcha).and_return(true)

      expect do
        post contact_path, params: valid_params
      end.to change(ActionMailer::Base.deliveries, :size).by(1)

      expect(response).to redirect_to(contact_path)
      follow_redirect!
      expect(response.body).to include("お問い合わせを受け付けました。")
    end

    it "リキャプチャが失敗すると422になる" do
      allow_any_instance_of(PagesController).to receive(:verify_recaptcha).and_return(false)

      post contact_path, params: valid_params

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "バリデーションエラー時は422になる" do
      allow_any_instance_of(PagesController).to receive(:verify_recaptcha).and_return(true)

      post contact_path, params: { contact_form: { name: "", email: "", subject: "", message: "", website: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "スパム判定は成功扱いでリダイレクトする" do
      allow_any_instance_of(PagesController).to receive(:verify_recaptcha).and_return(true)

      post contact_path, params: {
        contact_form: valid_params[:contact_form].merge(website: "http://spam.example.com")
      }

      expect(response).to redirect_to(contact_path)
    end
  end
end

RSpec.describe "トップページのおすすめ表示", type: :request do
  it "未ログインではおすすめを表示しない" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include(I18n.t("pages.home.recommendations_title"))
  end

  it "ログイン時におすすめが表示される" do
    user = create(:user)
    product = create(:product, name: "Recommend")
    create(:product_stat, product: product, reviews_count: 0)

    allow_any_instance_of(Recommendations::ProductRecommender)
      .to receive(:recommend)
      .and_return([ product ])

    sign_in user, scope: :user
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("pages.home.recommendations_title"))
    expect(response.body).to include("Recommend")
  end
end
