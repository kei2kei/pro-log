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

seed_image_dir = Rails.root.join("db/seed_images")

products.each_with_index do |attrs, index|
  product = Product.find_or_initialize_by(name: attrs[:name], brand: attrs[:brand], flavor: attrs[:flavor])
  product.assign_attributes(attrs)
  product.save!

  next if product.image.attached?

  image_path = seed_image_dir.join(format("product_%02d.png", index + 1))
  next unless File.exist?(image_path)

  product.image.attach(
    io: File.open(image_path),
    filename: image_path.basename.to_s,
    content_type: "image/png"
  )
end
