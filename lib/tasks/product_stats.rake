namespace :product_stats do
  desc "既存プロダクトの集計"
  task backfill: :environment do
    Product.find_each do |product|
      ProductStat.refresh_for(product.id)
    end
    puts "集計完了"
  end
end
