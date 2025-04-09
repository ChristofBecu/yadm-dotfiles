#!/bin/bash

GROQ_API_URL="https://api.groq.com/openai/v1"
DEFAULT_MODEL="qwen-2.5-coder-32b"

# Controleer of de API-key is ingesteld
if [ -z "$GROQ_API_KEY" ]; then
  echo "Fout: GROQ_API_KEY is niet ingesteld."
  exit 1
fi

# Map en bestand voor geschiedenisbeheer
HISTORY_DIR="$HOME/ai_histories"
CURRENT_HISTORY="$HISTORY_DIR/current_history.json"

# Zorg dat de geschiedenismap bestaat
mkdir -p "$HISTORY_DIR"

# Functie om een nieuwe geschiedenis te starten
start_new_history() {
  local prompt="$1"
  if [ -f "$CURRENT_HISTORY" ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    TITLE=$(echo "$prompt" | tr ' ' '_' | tr -cd '[:alnum:]_')
    mv "$CURRENT_HISTORY" "$HISTORY_DIR/history_${TITLE}_${TIMESTAMP}.json"
  fi
  echo '[]' > "$CURRENT_HISTORY"
  echo "$prompt" | jq -R --arg role "user" '. | {"role": $role, "content": .}' > "$CURRENT_HISTORY"
}

# Functie om een prompt toe te voegen aan de huidige geschiedenis
add_to_history() {
  local role="$1"
  local content="$2"
  jq --arg role "$role" --arg content "$content" '. + [{"role": $role, "content": $content}]' "$CURRENT_HISTORY" > "${CURRENT_HISTORY}.tmp"
  mv "${CURRENT_HISTORY}.tmp" "$CURRENT_HISTORY"
}

# Controleer het eerste argument
if [ "$1" == "new" ]; then
  if [ -z "$2" ]; then
    echo "Gebruik: $0 new \"prompt\""
    exit 1
  fi
  start_new_history "$2"
  echo "Nieuwe geschiedenis gestart met prompt: \"$2\""
#   exit 0
fi

# Als geen prompt is meegegeven, geef een foutmelding
if [ -z "$1" ]; then
  echo "Gebruik: $0 [new \"prompt\" | \"prompt\"] [model (optioneel)]"
  exit 1
fi

# Bepaal het model (standaard is qwen-2.5-coder-32b)
PROMPT="$1"
MODEL="${2:-$DEFAULT_MODEL}"

# Controleer of het huidige geschiedenisbestand bestaat, anders initialiseer het
if [ ! -f "$CURRENT_HISTORY" ]; then
  echo '[]' > "$CURRENT_HISTORY"
fi

# Voeg de huidige prompt toe aan de geschiedenis
add_to_history "user" "$PROMPT"

# Bouw de JSON-payload met de geschiedenis
HISTORY=$(cat "$CURRENT_HISTORY")
JSON_PAYLOAD=$(jq -n --arg model "$MODEL" --argjson messages "$HISTORY" '{
  "model": $model,
  "messages": $messages
}')

# Start de timer en voer de API-aanroep uit
START_TIME=$(date +%s)

RESPONSE=$(curl -s -X POST "$GROQ_API_URL/chat/completions" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")

END_TIME=$(date +%s)
TIME_TAKEN=$((END_TIME - START_TIME))

# Haal het antwoord uit de JSON-response
ANSWER=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

# Voeg het antwoord toe aan de geschiedenis
add_to_history "assistant" "$ANSWER"

# Toon het antwoord en de tijd die het heeft gekost
echo "$ANSWER"
echo "Tijd voor antwoord: $TIME_TAKEN seconden."