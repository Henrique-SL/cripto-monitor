package models

type CryptoData struct {
	ID                       string  `json:"id"`
	Symbol                   string  `json:"symbol"`
	Name                     string  `json:"name"`
	Image                    string  `json:"image"`
	CurrentPrice             float64 `json:"current_price"`
	MarketCapRank            int     `json:"market_cap_rank"`
	PriceChangePercentage24h float64 `json:"price_change_percentage_24h"`
	TotalVolume              float64 `json:"total_volume"`
	ATH                      float64 `json:"ath"`
	ATHChangePercentage      float64 `json:"ath_change_percentage"`
}
