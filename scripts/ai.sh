#!/bin/bash

GROQ_API_URL="https://api.groq.com/openai/v1"
DEFAULT_MODEL="llama-3.3-70b-specdec"

# Controleer of de API-key is ingesteld
if [ -z "$GROQ_API_KEY" ]; then
  echo "Fout: GROQ_API_KEY is niet ingesteld."
  exit 1
fi

# Functie om beschikbare modellen op te halen en te formatteren
list_models() {
  curl -s -X GET "$GROQ_API_URL/models" \
    -H "Authorization: Bearer $GROQ_API_KEY" | jq -r '
      .data[] | 
      (.created | strftime("%Y-%m-%d %H:%M:%S")) as $date |
      "\(.id) | Eigenaar: \(.owned_by) | Aangemaakt: \($date)"'
}

# Als argument --list is, toon de modellen
if [ "$1" == "--list" ]; then
  echo "Beschikbare modellen:"
  list_models
  exit 0
fi

# Als geen prompt is meegegeven, geef een foutmelding
if [ -z "$1" ]; then
  echo "Gebruik: $0 [--list | \"prompt\"] [model (optioneel)]"
  exit 1
fi

# Bepaal het model (standaard is qwen-2.5-coder-32b)
PROMPT="$1"
MODEL="${2:-$DEFAULT_MODEL}"

# Bouw de JSON-payload
JSON_PAYLOAD=$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT" '{
  "model": $model,
  "messages": [{"role": "user", "content": $prompt}]
}')

# Start de timer en voer de API-aanroep uit
START_TIME=$(date +%s)

RESPONSE=$(curl -s -X POST "$GROQ_API_URL/chat/completions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")

END_TIME=$(date +%s)
TIME_TAKEN=$((END_TIME - START_TIME))

# Haal het antwoord uit de JSON-response en toon het
ANSWER=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

# Toon het antwoord en de tijd die het heeft gekost
echo "$ANSWER"
echo "Tijd voor antwoord: $TIME_TAKEN seconden."
