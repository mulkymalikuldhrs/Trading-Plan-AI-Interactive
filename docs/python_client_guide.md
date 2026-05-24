# 🐍 Python & Google Colab Integration Guide

This guide provides instructions on how to interact with the Dhaher Trading Plan AI™ programmatically using the provided Python client and the Google Colab notebook.

## 1. Setting Up the Python Client

The `python_client/dhaher_ai_client.py` file contains a simple class that allows you to call all the major functions of the Google Apps Script API.

### Initialization

To use the client, you must first initialize it with your deployed Google Apps Script Web App URL:

```python
from dhaher_ai_client import DhaherAiClient

APPS_SCRIPT_URL = "YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL"
client = DhaherAiClient(APPS_SCRIPT_URL)
```

## 2. Using the Google Colab Notebook

The `Dhaher_AI_Colab_Notebook.ipynb` provides the easiest way to get started. It's an interactive environment where you can run code, analyze data, and visualize results.

### How to Use the Notebook:

1.  **Open in Google Colab:** Upload the `.ipynb` file to your Google Drive and open it with Google Colaboratory.
2.  **Upload the Client:** In the file browser on the left side of the Colab interface, click the "Upload" button and select the `dhaher_ai_client.py` file.
3.  **Install Dependencies:** Run the first code cell (`!pip install...`) to install the necessary Python libraries.
4.  **Configure Your URL:** In the second code cell, replace the placeholder URL with your actual, deployed Google Apps Script URL.
5.  **Run the Cells:** Execute the remaining cells one by one to see examples of:
    *   Fetching and analyzing your entire trade journal with `pandas`.
    *   Getting an on-demand AI forecast for any symbol.
    *   Programmatically logging a new trade.

## 3. Example Client Usage

Here are some examples of how you can use the client in your own Python scripts:

### Get a Forecast
```python
forecast = client.get_forecast('BTCUSD')
print(forecast)
```

### Get Journal Data as a Pandas DataFrame
```python
import pandas as pd

journal_data = client.get_journal_data()
df = pd.DataFrame(journal_data)
print(df.tail())
```

### Log a New Trade
```python
my_trade = {
    'pair': 'ETH/USD', 'direction': 'Sell', 'entry': 3500, 'sl': 3600, 'tp': 3200,
    'rrr': 3, 'setup': 'Supply Zone', 'mood': 'Focused', 'ai_status': 'Approved',
    'result': 'LOSS', 'emotion_after': 'Neutral', 'gpt_comment': 'Market structure shifted.'
}
client.log_trade(my_trade)
```

This programmatic access opens up endless possibilities for advanced data analysis, backtesting trading strategies, and integrating the Dhaher Trading Plan AI with other systems.

---

> **Contact:** Mulky Malikul Dhaher — [mulkymalikuldhaher@email.com](mailto:mulkymalikuldhaher@email.com)
>
> **Disclaimer:** This project is for Education Purpose only. Risiko apapun tidak kita tanggung. (We are not responsible for any risks or damages.)
