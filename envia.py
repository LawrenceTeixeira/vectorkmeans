import requests
import json

def send_kmeans_request():
    """
    Sends a POST request to the KMeans API endpoint with the specified data.

    Returns:
        None

    Raises:
        requests.exceptions.RequestException: If an error occurs while sending the request.
    """
    # The URL for the API endpoint
    url = 'http://localhost:8000/kmeans/build'  # Replace http://example.com with the actual domain

    # The data to be sent in the POST request
    data = {
        "table": {
            "schema": "dbo",
            "name": "news"
        },
        "column": {
            "id": "article_id",
            "vector": "content_vector"
        },
        "vector": {
            "dimensions": 1536
        }
    }

    # Convert the Python dictionary to a JSON string
    data_json = json.dumps(data)

    # Specify the content type for the request
    headers = {'Content-Type': 'application/json'}

    try:
        # Sending the POST request
        response = requests.post(url, data=data_json, headers=headers)

        # Checking the response from the server
        if response.status_code == 200:
            print("Request was successful.")
            print("Response:", response.json())
        else:
            print(f"Request failed with status code: {response.status_code}")
            print("Response:", response.text)
    except requests.exceptions.RequestException as e:
        print("An error occurred while sending the request:", str(e))

# Call the function to send the KMeans request
send_kmeans_request()
