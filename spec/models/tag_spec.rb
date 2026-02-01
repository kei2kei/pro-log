require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "Tag#バリデーションチェック" do
    it "正常系の確認" do
      expect(build(:tag)).to be_valid
    end

    it "タグ名の必須エラー確認" do
      tag = build(:tag, name: nil)
      expect(tag).not_to be_valid
    end

    it "タグ名は大文字小文字を区別せず一意である" do
      create(:tag, name: "Protein")
      tag = build(:tag, name: "protein")
      expect(tag).not_to be_valid
    end
  end

  describe ".normalize_names" do
    it "区切り文字と空白を正規化して一意化する" do
      result = Tag.normalize_names("  バナナ, チョコ　抹茶 / バナナ ")
      expect(result).to contain_exactly("バナナ", "チョコ", "抹茶")
    end
  end
end
