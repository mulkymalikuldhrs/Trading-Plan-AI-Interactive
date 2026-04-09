import requests
import json
import os

class DhaherAiClient:
    """
    A Python client for interacting with the Dhaher Trading Plan AI Google Apps Script API.
    """
    def __init__(self, apps_script_url=None, api_key=None):
        # Priority: Constructor Argument > Environment Variable
        self.api_url = apps_script_url or os.getenv('GAS_URL')
        self.api_key = api_key or os.getenv('API_KEY')

        if not self.api_url or "YOUR_DEPLOYMENT_ID" in self.api_url or "YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL" in self.api_url:
            raise ValueError("Google Apps Script URL is not set. Please provide it in the constructor or set the GAS_URL environment variable.")

    def _post_request(self, action, data={}):
        """Helper function to make POST requests to the API."""
        payload = {
            'action': action,
            'data': data,
            'api_key': self.api_key
        }
        try:
            response = requests.post(self.api_url, json=payload, headers={'Content-Type': 'application/json'})
            response.raise_for_status()

            result = response.json()
            if result.get('status') == 'success':
                return result.get('data')
            else:
                raise Exception(f"API Error: {result.get('message', 'Unknown error')}")

        except requests.exceptions.RequestException as e:
            raise Exception(f"HTTP Request failed: {e}")
        except json.JSONDecodeError:
            raise Exception(f"Failed to decode JSON response. Response text: {response.text}")


    def get_ai_summary(self, symbol='EURUSD'):
        """Fetches the AI's master summary for a given symbol."""
        return self._post_request('getAiMasterSummary', {'symbol': symbol})

    def get_forecast(self, symbol='EURUSD', timeframe='H4', days=7):
        """Fetches the AI's forecast for a given symbol."""
        return self._post_request('getForecast', {'pair': symbol, 'timeframe': timeframe, 'days': days})

    def get_journal_data(self):
        """Exports the entire trading journal as a list of dictionaries."""
        json_string_data = self._post_request('exportToJson', {'sheetName': 'Journal'})
        if isinstance(json_string_data, str):
            return json.loads(json_string_data)
        return json_string_data

    def log_trade(self, trade_data):
        """Logs a new trade to the journal."""
        return self._post_request('logTrade', trade_data)

    def log_violation(self, trade_id, rule, justification):
        """Logs a rule violation."""
        return self._post_request('logViolation', {'tradeId': trade_id, 'ruleBroken': rule, 'justification': justification})

# Example Usage:
if __name__ == '__main__':
    # Set the environment variable GAS_URL before running, or pass it here.
    try:
        client = DhaherAiClient()
        journal = client.get_journal_data()
        print(f"Successfully fetched {len(journal)} journal entries.")
    except Exception as e:
        print(f"Error: {e}")
