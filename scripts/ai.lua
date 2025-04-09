-- ai.lua

local GROQ_API_URL = "https://api.groq.com/openai/v1"
local DEFAULT_MODEL = "llama-3.3-70b-specdec"

-- Controleer of de API-key is ingesteld
local GROQ_API_KEY = os.getenv("GROQ_API_KEY")
if not GROQ_API_KEY then
  print("Fout: GROQ_API_KEY is niet ingesteld.")
  os.exit(1)
end

-- Map en bestand voor geschiedenisbeheer
local HOME = os.getenv("HOME")
local HISTORY_DIR = HOME .. "/ai_histories"
local CURRENT_HISTORY = HISTORY_DIR .. "/current_history.json"

-- Zorg dat de geschiedenismap bestaat
os.execute("mkdir -p " .. HISTORY_DIR)

-- Functie om beschikbare modellen op te halen en te formatteren
local function list_models()
  local handle = io.popen("curl -s -X GET " .. GROQ_API_URL .. "/models -H 'Authorization: Bearer " .. GROQ_API_KEY .. "'")
  local result = handle:read("*a")
  handle:close()
  local json = require("dkjson")
  local data = json.decode(result)
  for _, model in ipairs(data.data) do
    local date = os.date("%Y-%m-%d %H:%M:%S", model.created)
    print(string.format("%s | Eigenaar: %s | Aangemaakt: %s", model.id, model.owned_by, date))
  end
end

-- Functie om een nieuwe geschiedenis te starten
local function start_new_history(prompt)
  if os.execute("[ -f " .. CURRENT_HISTORY .. " ]") then
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local title = prompt:gsub(" ", "_"):gsub("[^%w_]", "")
    os.rename(CURRENT_HISTORY, HISTORY_DIR .. "/history_" .. title .. "_" .. timestamp .. ".json")
  end
  local file = io.open(CURRENT_HISTORY, "w")
  file:write("[]")
  file:close()
  local json = require("dkjson")
  local history = {{role = "user", content = prompt}}
  local history_file = io.open(CURRENT_HISTORY, "w")
  history_file:write(json.encode(history, {indent = true}))
  history_file:close()
end

-- Functie om een prompt toe te voegen aan de geschiedenis
local function add_to_history(role, content)
  local json = require("dkjson")
  local file = io.open(CURRENT_HISTORY, "r")
  local history = json.decode(file:read("*a"))
  file:close()
  table.insert(history, {role = role, content = content})
  local history_file = io.open(CURRENT_HISTORY, "w")
  history_file:write(json.encode(history, {indent = true}))
  history_file:close()
end

-- Functie om een chat te starten
local function chat(prompt, model)
  model = model or DEFAULT_MODEL
  if not prompt then
    print("Gebruik: lua ai.lua [new \"prompt\" | \"prompt\"] [model (optioneel)]")
    os.exit(1)
  end

  if not io.open(CURRENT_HISTORY, "r") then
    local file = io.open(CURRENT_HISTORY, "w")
    file:write("[]")
    file:close()
  end

  add_to_history("user", prompt)

  local json = require("dkjson")
  local file = io.open(CURRENT_HISTORY, "r")
  local history = json.decode(file:read("*a"))
  file:close()

  local payload = {
    model = model,
    messages = history
  }

  -- Gebruik dkjson om de payload te serialiseren
  local payload_json = json.encode(payload, {indent = false})
  print("Payload verzonden naar API:")
  print(payload_json) -- Debugging: toon de payload

  -- Escape dubbele aanhalingstekens voor de shell-opdracht
  local escaped_payload = payload_json:gsub('"', '\\"')

  local start_time = os.time()
  local command = string.format(
    "curl -s -X POST %s/chat/completions -H 'Authorization: Bearer %s' -H 'Content-Type: application/json' -d \"%s\"",
    GROQ_API_URL, GROQ_API_KEY, escaped_payload
  )
  local handle = io.popen(command)
  local response = handle:read("*a")
  handle:close()
  local end_time = os.time()

  print("Respons ontvangen van API:")
  print(response) -- Debugging: toon de volledige respons

  -- Decodeer de respons
  local data, pos, err = json.decode(response)
  if not data then
    print("Fout bij het decoderen van de API-respons: " .. (err or "onbekende fout"))
    print("Respons ontvangen: " .. response)
    os.exit(1)
  end

  -- Controleer of het veld 'choices' bestaat
  if not data.choices or not data.choices[1] or not data.choices[1].message then
    print("Ongeldige API-respons ontvangen:")
    print(response)
    os.exit(1)
  end

  local answer = data.choices[1].message.content
  print(answer)
  print("Tijd voor antwoord: " .. os.difftime(end_time, start_time) .. " seconden.")

  add_to_history("assistant", answer)
  print("Antwoord toegevoegd aan de geschiedenis.")
end

-- Verwerk argumenten
local args = {...}
if args[1] == "list" then
  print("Beschikbare modellen:")
  list_models()
elseif args[1] == "history" then
  local handle = io.popen("ls -1 " .. HISTORY_DIR .. " | sort")
  local result = handle:read("*a")
  handle:close()
  if result == "" then
    print("Geen geschiedenis gevonden.")
  else
    print("Beschikbare geschiedenisbestanden:")
    print(result)
  end
elseif args[1] == "new" then
  if not args[2] then
    print("Gebruik: lua ai.lua new \"prompt\"")
    os.exit(1)
  end
  start_new_history(args[2])
  print("Nieuwe geschiedenis gestart met prompt: \"" .. args[2] .. "\"")
  chat(args[2], args[3])
else
  chat(args[1], args[2])
end