package handlers

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"

	"monitor-cripto/go-api/database"
	"monitor-cripto/go-api/models"

	"github.com/gorilla/mux"
)

func ReceiveCryptoData(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Método não permitido", http.StatusMethodNotAllowed)
		return
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Erro ao ler o corpo da requisição", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	var dados []models.CryptoData
	err = json.Unmarshal(body, &dados)
	if err != nil {
		http.Error(w, "Erro ao decodificar JSON", http.StatusBadRequest)
		return
	}

	tx, err := database.DB.Begin()
	if err != nil {
		http.Error(w, "Erro iniciando transação", http.StatusInternalServerError)
		return
	}

	stmt, err := tx.Prepare(`INSERT OR REPLACE INTO crypto
		(id, symbol, name, image, current_price, market_cap_rank, price_change_percentage_24h, total_volume, ath, ath_change_percentage)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		tx.Rollback()
		http.Error(w, "Erro preparando statement", http.StatusInternalServerError)
		return
	}
	defer stmt.Close()

	for _, crypto := range dados {
		// --- LOG NOVO ADICIONADO AQUI ---
		log.Printf("Tentando inserir: ID=%s, Nome=%s, Imagem=%s", crypto.ID, crypto.Name, crypto.Image)

		_, err = stmt.Exec(
			crypto.ID,
			crypto.Symbol,
			crypto.Name,
			crypto.Image,
			crypto.CurrentPrice,
			crypto.MarketCapRank,
			crypto.PriceChangePercentage24h,
			crypto.TotalVolume,
			crypto.ATH,
			crypto.ATHChangePercentage,
		)
		if err != nil {
			tx.Rollback()
			log.Printf("Erro inserindo dados no banco: %v", err)
			http.Error(w, "Erro inserindo dados no banco", http.StatusInternalServerError)
			return
		}
	}

	err = tx.Commit()
	if err != nil {
		http.Error(w, "Erro salvando transação", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Dados recebidos e salvos com sucesso!"))
}

func GetCryptos(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query("SELECT id, symbol, name, image, current_price, market_cap_rank, price_change_percentage_24h, total_volume, ath, ath_change_percentage FROM crypto ORDER BY market_cap_rank ASC")
	if err != nil {
		http.Error(w, "Erro ao consultar banco", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	cryptos := make([]models.CryptoData, 0)

	for rows.Next() {
		var c models.CryptoData
		err = rows.Scan(&c.ID, &c.Symbol, &c.Name, &c.Image, &c.CurrentPrice, &c.MarketCapRank, &c.PriceChangePercentage24h, &c.TotalVolume, &c.ATH, &c.ATHChangePercentage)
		if err != nil {
			http.Error(w, "Erro ao ler dados do banco", http.StatusInternalServerError)
			return
		}
		cryptos = append(cryptos, c)
	}

	if err = rows.Err(); err != nil {
		http.Error(w, "Erro ao iterar resultados do banco", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(cryptos)
}

func GetMarketChart(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	days := r.URL.Query().Get("days")
	if days == "" {
		days = "7"
	}

	url := fmt.Sprintf("https://api.coingecko.com/api/v3/coins/%s/market_chart?vs_currency=usd&days=%s", id, days)

	resp, err := http.Get(url)
	if err != nil {
		http.Error(w, "Falha ao buscar dados da CoinGecko", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	w.Header().Set("Content-Type", "application/json")
	io.Copy(w, resp.Body)
}
