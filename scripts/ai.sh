#!/bin/bash

GROQ_API_URL="https://api.groq.com/openai/v1"
DEFAULT_MODEL="llama-3.3-70b-specdec"
#DEFAULT_MODEL="qwen-2.5-coder-32b"


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

# Variabelen
if [ "$1" = "new" ]; then
  PROMPT="$2"
else
  PROMPT="$1"
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
if [ "$1" == "list" ]; then
  echo "Beschikbare modellen:"
  list_models
  exit 0
fi

# Toon alle geschiedenisbestanden als 'history' als argument is meegegeven
if [ "$1" == "history" ]; then
  if [ ! -d "$HISTORY_DIR" ]; then
    echo "Geen geschiedenis gevonden."
    exit 0
  fi
  echo "Beschikbare geschiedenisbestanden:"
  ls -1 "$HISTORY_DIR" | sort
  exit 0
fi

if [ -z "$PROMPT" ]; then
  echo "Gebruik: $0 [new \"prompt\" | \"prompt\"] [model (optioneel)]"
  exit 1
fi

MODEL=""
RESPONSE=""
ANSWER=""
TIME_TAKEN=0
TIMESTAMP=""
TITLE=""


start_new_history() {
  local prompt="$1"
  if [ -f "$CURRENT_HISTORY" ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    TITLE=$(echo "$prompt" | tr ' ' '_' | tr -cd '[:alnum:]_')
    mv "$CURRENT_HISTORY" "$HISTORY_DIR/history_${TITLE}_${TIMESTAMP}.json"
  fi
  echo "[]" > "$CURRENT_HISTORY"
  jq -n --arg role "user" --arg content "$prompt" '[{"role": $role, "content": $content}]' > "$CURRENT_HISTORY"
}

echo $PROMPT
# exit 0


if [ "$1" == "new" ]; then
  if [ -z "$2" ]; then
    echo "Gebruik: $0 new \"prompt\""
    exit 1
  fi
  # Start een nieuwe geschiedenis met de opgegeven prompt
  start_new_history "$2"
  echo "Nieuwe geschiedenis gestart met prompt: \"$2\""
fi

# Als geen prompt is meegegeven, geef een foutmelding
if [ -z "$PROMPT" ]; then
  echo "Gebruik: $0 [list] | [new | \"prompt\"] [model (optioneel)]"
  exit 1
fi



if [ "$1" == "new" ]; then
  MODEL="${3:-$DEFAULT_MODEL}"
else
  MODEL="${2:-$DEFAULT_MODEL}"
fi

# haal de huidige geschiedenis op en voeg toe aan de payload
if [ ! -f "$CURRENT_HISTORY" ]; then
  echo '[]' > "$CURRENT_HISTORY"
fi
# Voeg de huidige prompt toe aan de geschiedenis
add_to_history() {
  local role="$1"
  local content="$2"
  jq --arg role "$role" --arg content "$content" '. + [{"role": $role, "content": $content}]' "$CURRENT_HISTORY" > "${CURRENT_HISTORY}.tmp"
  mv "${CURRENT_HISTORY}.tmp" "$CURRENT_HISTORY"
}

add_to_history "user" "$PROMPT"

# Bouw de JSON-payload met de geschiedenis
HISTORY=$(cat "$CURRENT_HISTORY")
JSON_PAYLOAD=$(jq -n --arg model "$MODEL" --argjson messages "$HISTORY" '{
  "model": $model,
  "messages": $messages
}')





# Bouw de JSON-payload
# JSON_PAYLOAD=$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT" '{
#   "model": $model,
#   "messages": [{"role": "user", "content": $prompt}]
# }')

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

# Voeg het antwoord toe aan de geschiedenis
add_to_history() {
  local role="$1"
  local content="$2"
  jq --arg role "$role" --arg content "$content" '. + [{"role": $role, "content": $content}]' "$CURRENT_HISTORY" > "${CURRENT_HISTORY}.tmp"
  mv "${CURRENT_HISTORY}.tmp" "$CURRENT_HISTORY"
}

add_to_history "assistant" "$ANSWER"
echo "Antwoord toegevoegd aan de geschiedenis."


