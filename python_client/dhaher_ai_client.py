import requests
import json

class DhaherAiClient:
    """
    A Python client for interacting with the Dhaher Trading Plan AI Google Apps Script API.
    """
    def __init__(self, apps_script_url, api_key=None):
        if not apps_script_url or "YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL" in apps_script_url:
            raise ValueError("Google Apps Script URL is not set or is a placeholder.")
        self.api_url = apps_script_url
        self.api_key = api_key

    def _post_request(self, action, data=None):
        """Helper function to make POST requests to the API."""
        if data is None:
            data = {}

        # Inject API Key if available
        if self.api_key:
            data['apiKey'] = self.api_key

        payload = {
            'action': action,
            'data': data
        }
        try:
            response = requests.post(self.api_url, json=payload, headers={'Content-Type': 'application/json'})
            response.raise_for_status()  # Raise an exception for bad status codes

            # Google Apps Script can sometimes return a redirect, handle it
            if response.history:
                print("Request was redirected. Final URL:", response.url)

            result = response.json()
            if result.get('status') == 'success':
                data = result.get('data')
                # GAS sometimes returns a stringified JSON if it's a complex object
                if isinstance(data, str):
                    try:
                        return json.loads(data)
                    except json.JSONDecodeError:
                        return data
                return data
            else:
                raise Exception(f"API Error: {result.get('message', 'Unknown error')}")

        except requests.exceptions.RequestException as e:
            raise Exception(f"HTTP Request failed: {e}")
        except json.JSONDecodeError:
            raise Exception(f"Failed to decode JSON response. Response text: {response.text}")


    def get_ai_summary(self, symbol='EURUSD'):
        """Fetches the AI's master summary for a given symbol."""
        print(f"Fetching AI summary for {symbol}...")
        return self._post_request('getAiMasterSummary', {'symbol': symbol})

    def get_forecast(self, symbol='EURUSD', timeframe='H4', days=7):
        """Fetches the AI's forecast for a given symbol."""
        print(f"Fetching forecast for {symbol} ({timeframe}, {days} days)...")
        return self._post_request('getForecast', {'pair': symbol, 'timeframe': timeframe, 'days': days})

    def get_journal_data(self):
        """Exports the entire trading journal as a list of dictionaries."""
        print("Fetching journal data...")
        # The data from exportSheetToJson is a JSON string, so we need to parse it.
        json_string_data = self._post_request('exportToJson', {'sheetName': 'Journal'})
        if isinstance(json_string_data, str):
            return json.loads(json_string_data)
        return json_string_data # Should already be a list/dict

    def log_trade(self, trade_data):
        """Logs a new trade to the journal."""
        # Example trade_data:
        # {
        #   'pair': 'BTC/USD', 'direction': 'Buy', 'entry': 60000, 'sl': 59000, 'tp': 65000,
        #   'rrr': 5, 'setup': 'Breakout', 'mood': 'Confident', 'ai_status': 'Approved',
        #   'result': 'WIN', 'emotion_after': 'Elated', 'gpt_comment': 'Good trade.'
        # }
        print(f"Logging trade for {trade_data.get('pair')}...")
        return self._post_request('logTrade', trade_data)

    def log_violation(self, trade_id, rule, justification):
        """Logs a rule violation."""
        print(f"Logging violation for trade {trade_id}...")
        return self._post_request('logViolation', {'tradeId': trade_id, 'ruleBroken': rule, 'justification': justification})

# Example Usage:
if __name__ == '__main__':
    # This is for testing purposes. Replace with your actual deployed URL and API Key.
    # The script will raise a ValueError if this is a placeholder URL.
    APPS_SCRIPT_URL = "YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL"
    BOT_API_KEY = "YOUR_BOT_API_KEY"

    try:
        client = DhaherAiClient(APPS_SCRIPT_URL, BOT_API_KEY)

        # --- Get Journal Data ---
        journal = client.get_journal_data()
        print(f"Successfully fetched {len(journal)} journal entries.")
        # print(journal[0] if journal else "Journal is empty.")

        # --- Get a Forecast ---
        # forecast = client.get_forecast('GOLD')
        # print("\nForecast for GOLD:")
        # print(json.dumps(forecast, indent=2))

    except ValueError as e:
        print(f"\nError: {e}")
        print("Please replace 'YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL' with your actual deployed URL.")
    except Exception as e:
        print(f"\nAn error occurred: {e}")
