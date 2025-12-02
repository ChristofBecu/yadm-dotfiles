#!/bin/bash

#GROQ_API_URL="https://api.groq.com/openai/v1"
#DEFAULT_MODEL="qwen-2.5-coder-32b"
GROQ_API_URL="https://openrouter.ai/api/v1"
DEFAULT_MODEL="gpt-3.5-turbo"
GROQ_API_KEY="" # Vervang dit door je eigen API-key

# Controleer of de API-key is ingesteld
if [ -z "$GROQ_API_KEY" ]; then
  echo "Fout: GROQ_API_KEY is niet ingesteld."
  exit 1
fi

# Functie om beschikbare modellen op te halen met mooie opmaak
list_models() {
  curl -s -X GET "$GROQ_API_URL/models" \
    -H "Authorization: Bearer $GROQ_API_KEY" | jq -r '
      .data[] | 
      (.created | strftime("%Y-%m-%d %H:%M:%S")) as $date |
      "\(.id) | Eigenaar: \(.owned_by) | Aangemaakt: \($date)"'
}

# Haal de lijst van modellen op en toon het
MODELS=$(list_models)

echo "Beschikbare modellen:"
echo "$MODELS"
echo "----------------------------------------"

# Array om tijden op te slaan
declare -A model_times

# Test elk model
for MODEL in $(echo "$MODELS" | awk '{print $1}'); do
  echo "Testen van model: $MODEL"
  
  # Bouw de JSON-payload voor elk model
  JSON_PAYLOAD=$(jq -n --arg model "$MODEL" --arg prompt "$1" '{
    "model": $model,
    "messages": [{"role": "user", "content": $prompt}]
  }')

  # Start de timer in milliseconden
  START_TIME=$(date +%s%3N)

  # Voer de API-aanroep uit zonder het antwoord op te slaan
  curl -s -X POST "$GROQ_API_URL/chat/completions" \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD" > /dev/null

  END_TIME=$(date +%s%3N)
  TIME_TAKEN=$((END_TIME - START_TIME))

  # Bewaar de tijd voor dit model in milliseconden
  model_times["$MODEL"]=$TIME_TAKEN
done

# Toon de verzamelde tijden gesorteerd op de snelste tijd
echo "----------------------------------------"
echo "Tijd voor antwoord per model (gesorteerd op snelste):"

for MODEL in $(for key in "${!model_times[@]}"; do echo "$key ${model_times[$key]}"; done | sort -k2 -n | awk '{print $1}'); do
  echo "$MODEL: ${model_times[$MODEL]} ms"
done


