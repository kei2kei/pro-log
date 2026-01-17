products = [
  { name: "Impact Whey", brand: "MyProtein", price: 3980, flavor: "チョコ", protein_type: :whey, calorie: 412, protein: 80, fat: 6, carbohydrate: 7 },
  { name: "Impact Whey", brand: "MyProtein", price: 3980, flavor: "ストロベリー", protein_type: :whey, calorie: 410, protein: 79, fat: 6, carbohydrate: 8 },
  { name: "Impact Whey", brand: "MyProtein", price: 3980, flavor: "バナナ", protein_type: :whey, calorie: 411, protein: 80, fat: 6, carbohydrate: 8 },
  { name: "Impact Whey", brand: "MyProtein", price: 3980, flavor: "抹茶", protein_type: :whey, calorie: 409, protein: 78, fat: 5, carbohydrate: 9 },
  { name: "Whey 100", brand: "SAVAS", price: 4480, flavor: "チョコ", protein_type: :whey, calorie: 414, protein: 76, fat: 5, carbohydrate: 10 },
  { name: "Whey 100", brand: "SAVAS", price: 4480, flavor: "ストロベリー", protein_type: :whey, calorie: 413, protein: 75, fat: 5, carbohydrate: 11 },
  { name: "Whey 100", brand: "SAVAS", price: 4480, flavor: "バナナ", protein_type: :whey, calorie: 415, protein: 76, fat: 5, carbohydrate: 10 },
  { name: "Whey 100", brand: "SAVAS", price: 4480, flavor: "抹茶", protein_type: :whey, calorie: 412, protein: 74, fat: 5, carbohydrate: 12 },
  { name: "Gold Standard", brand: "ON", price: 5280, flavor: "チョコ", protein_type: :whey, calorie: 410, protein: 79, fat: 4, carbohydrate: 8 },
  { name: "Gold Standard", brand: "ON", price: 5280, flavor: "ストロベリー", protein_type: :whey, calorie: 409, protein: 78, fat: 4, carbohydrate: 9 },
  { name: "Gold Standard", brand: "ON", price: 5280, flavor: "バナナ", protein_type: :whey, calorie: 411, protein: 79, fat: 4, carbohydrate: 8 },
  { name: "Gold Standard", brand: "ON", price: 5280, flavor: "抹茶", protein_type: :whey, calorie: 408, protein: 77, fat: 4, carbohydrate: 10 },
  { name: "BeLEGEND", brand: "BeLEGEND", price: 4380, flavor: "チョコ", protein_type: :blend, calorie: 416, protein: 72, fat: 7, carbohydrate: 12 },
  { name: "BeLEGEND", brand: "BeLEGEND", price: 4380, flavor: "ストロベリー", protein_type: :blend, calorie: 415, protein: 72, fat: 7, carbohydrate: 12 },
  { name: "BeLEGEND", brand: "BeLEGEND", price: 4380, flavor: "バナナ", protein_type: :blend, calorie: 417, protein: 71, fat: 7, carbohydrate: 13 },
  { name: "BeLEGEND", brand: "BeLEGEND", price: 4380, flavor: "抹茶", protein_type: :blend, calorie: 414, protein: 71, fat: 7, carbohydrate: 13 },
  { name: "Soy Clean", brand: "NatureLab", price: 2980, flavor: "抹茶", protein_type: :soy, calorie: 382, protein: 70, fat: 4, carbohydrate: 15 },
  { name: "Night Casein", brand: "Rule1", price: 4580, flavor: "チョコ", protein_type: :casein, calorie: 384, protein: 76, fat: 2, carbohydrate: 11 }
]

products.each_with_index do |attrs, index|
  product = Product.find_or_initialize_by(name: attrs[:name], brand: attrs[:brand], flavor: attrs[:flavor])
  product.assign_attributes(attrs)
  product.save!
end

seed_users = [
  { email: "demo@example.com", username: "demo" },
  { email: "alice@example.com", username: "alice" },
  { email: "bob@example.com", username: "bob" },
  { email: "carol@example.com", username: "carol" }
]

seed_users.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.username = attrs[:username]
    user.password = "password"
    user.password_confirmation = "password"
    user.skip_confirmation!
  end
end

demo_user = User.find_by!(email: "demo@example.com")
alice_user = User.find_by!(email: "alice@example.com")
bob_user = User.find_by!(email: "bob@example.com")
carol_user = User.find_by!(email: "carol@example.com")

review_templates = [
  {
    title: "溶けやすくて飲みやすい",
    comment: "朝の忙しい時間でもサッと溶けて助かります。甘さ控えめで続けやすい。",
    overall_score: 4,
    sweetness: 3,
    richness: 3,
    aftertaste: 4,
    flavor_score: 4,
    solubility: 5,
    foam: 4
  },
  {
    title: "コスパ重視ならこれ",
    comment: "価格に対してタンパク質量がしっかり。リピートしたい味です。",
    overall_score: 5,
    sweetness: 4,
    richness: 4,
    aftertaste: 4,
    flavor_score: 5,
    solubility: 4,
    foam: 3
  },
  {
    title: "甘さは控えめ",
    comment: "甘すぎないので食事と合わせやすい。後味が軽いのも良い。",
    overall_score: 4,
    sweetness: 2,
    richness: 3,
    aftertaste: 4,
    flavor_score: 3,
    solubility: 4,
    foam: 4
  }
]

Product.find_each do |product|
  template = review_templates.first
  Review.find_or_create_by!(
    user: demo_user,
    product: product,
    title: template[:title]
  ) do |review|
    review.comment = template[:comment]
    review.overall_score = template[:overall_score]
    review.sweetness = template[:sweetness]
    review.richness = template[:richness]
    review.aftertaste = template[:aftertaste]
    review.flavor_score = template[:flavor_score]
    review.solubility = template[:solubility]
    review.foam = template[:foam]
  end
end

extra_reviews = [
  {
    title: "クセが少なく続けやすい",
    comment: "後味が軽くて毎日続けやすいです。",
    overall_score: 5,
    sweetness: 3,
    richness: 4,
    aftertaste: 5,
    flavor_score: 4,
    solubility: 4,
    foam: 3
  },
  {
    title: "甘めで満足感あり",
    comment: "甘い系が好きならかなり良いと思います。",
    overall_score: 4,
    sweetness: 4,
    richness: 4,
    aftertaste: 3,
    flavor_score: 4,
    solubility: 3,
    foam: 3
  }
]

top_products = Product.order(:id).limit(5)

extra_reviewers = [ alice_user, bob_user ]

top_products.each do |product|
  extra_reviewers.each_with_index do |user, index|
    template = extra_reviews[index]
    Review.find_or_create_by!(
      user: user,
      product: product,
      title: template[:title]
    ) do |review|
      review.comment = template[:comment]
      review.overall_score = template[:overall_score]
      review.sweetness = template[:sweetness]
      review.richness = template[:richness]
      review.aftertaste = template[:aftertaste]
      review.flavor_score = template[:flavor_score]
      review.solubility = template[:solubility]
      review.foam = template[:foam]
    end
  end
end

top_products.first(3).each do |product|
  Review.find_or_create_by!(
    user: carol_user,
    product: product,
    title: "リピート候補"
  ) do |review|
    review.comment = "総合的にバランスが良いです。"
    review.overall_score = 5
    review.sweetness = 3
    review.richness = 4
    review.aftertaste = 4
    review.flavor_score = 4
    review.solubility = 5
    review.foam = 4
  end
end

bookmark_targets = Product.order(:id).limit(6)

bookmark_targets.first(2).each do |product|
  ProductBookmark.find_or_create_by!(user: demo_user, product: product)
end

bookmark_targets.first(4).each do |product|
  ProductBookmark.find_or_create_by!(user: alice_user, product: product)
end

bookmark_targets.first(5).each do |product|
  ProductBookmark.find_or_create_by!(user: bob_user, product: product)
end

bookmark_targets.first(6).each do |product|
  ProductBookmark.find_or_create_by!(user: carol_user, product: product)
end
