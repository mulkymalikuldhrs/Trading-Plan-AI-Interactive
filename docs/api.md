## API – Entry Validator

POST to LLM7 API → https://api.llm7.io/v1
Payload:

{
  "model": "gpt-3.5-turbo",
  "messages": [
    { "role": "system", "content": "You are my trading validator mentor..." },
    { "role": "user", "content": "[Prompt text]" }
  ]
}

Returns:
- validation: true/false
- feedback: string
