
collapse (sum) capitalexpenditures purchaseacquisitionofintangibles totalassets, by(year)

gen inv_at = -(capitalexpenditures+purchaseacquisitionofintangibles)/totalassets

line inv_at year
