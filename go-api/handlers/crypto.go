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
		log.Printf("Erro ao ler corpo da requisição: %v\n", err)
		http.Error(w, "Erro ao ler o corpo da requisição", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	var dados []models.CryptoData
	err = json.Unmarshal(body, &dados)
	if err != nil {
		log.Printf("Erro ao decodificar JSON: %v\n", err)
		http.Error(w, "Erro ao decodificar JSON", http.StatusBadRequest)
		return
	}

	tx, err := database.DB.Begin()
	if err != nil {
		log.Printf("Erro iniciando transação: %v\n", err)
		http.Error(w, "Erro iniciando transação", http.StatusInternalServerError)
		return
	}

	// VERSÃO CORRIGIDA COM 7 COLUNAS E 7 '?'
	stmt, err := tx.Prepare(`INSERT OR REPLACE INTO crypto
		(id, symbol, name, image, current_price, market_cap_rank, price_change_percentage_24h)
		VALUES (?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		log.Printf("Erro preparando statement: %v\n", err)
		http.Error(w, "Erro preparando statement", http.StatusInternalServerError)
		return
	}
	defer stmt.Close()

	for _, crypto := range dados {
		// VERSÃO CORRIGIDA COM 7 ARGUMENTOS
		_, err = stmt.Exec(
			crypto.ID,
			crypto.Symbol,
			crypto.Name,
			crypto.Image,
			crypto.CurrentPrice,
			crypto.MarketCapRank,
			crypto.PriceChangePercentage24h,
		)
		if err != nil {
			tx.Rollback()
			log.Printf("Erro inserindo dados no banco: %v\n", err)
			http.Error(w, "Erro inserindo dados no banco", http.StatusInternalServerError)
			return
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Erro salvando transação: %v\n", err)
		http.Error(w, "Erro salvando transação", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Dados recebidos e salvos com sucesso!"))
}

func GetCryptos(w http.ResponseWriter, r *http.Request) {
	// VERSÃO CORRIGIDA DO SELECT, INCLUINDO 'image'
	rows, err := database.DB.Query("SELECT id, symbol, name, image, current_price, market_cap_rank, price_change_percentage_24h FROM crypto ORDER BY market_cap_rank ASC")
	if err != nil {
		log.Printf("Erro ao consultar banco: %v\n", err)
		http.Error(w, "Erro ao consultar banco", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// VERSÃO CORRIGIDA PARA EVITAR RETORNO 'null'
	cryptos := make([]models.CryptoData, 0)

	for rows.Next() {
		var c models.CryptoData
		// VERSÃO CORRIGIDA DO SCAN, INCLUINDO '&c.Image'
		err = rows.Scan(&c.ID, &c.Symbol, &c.Name, &c.Image, &c.CurrentPrice, &c.MarketCapRank, &c.PriceChangePercentage24h)
		if err != nil {
			log.Printf("Erro ao ler dados do banco: %v\n", err)
			http.Error(w, "Erro ao ler dados do banco", http.StatusInternalServerError)
			return
		}
		cryptos = append(cryptos, c)
	}

	if err = rows.Err(); err != nil {
		log.Printf("Erro ao iterar resultados do banco: %v\n", err)
		http.Error(w, "Erro ao iterar resultados do banco", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(cryptos)
}

// GetMarketChart busca o histórico de mercado de uma cripto específica
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
