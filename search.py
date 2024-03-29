import streamlit as st
import pandas as pd
import pyodbc
import openai
import os
import time
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Set up OpenAI credentials from environment variables
openai.api_type = os.getenv('OPENAI_API_TYPE')
openai.api_key = os.getenv('OPENAI_API_KEY')
openai.api_base = os.getenv('OPENAI_API_BASE')
openai.api_version = os.getenv('OPENAI_API_VERSION')
# or from sqlalchemy import create_engine

# Function to connect to the database
def get_connection():
    with st.spinner('I am trying to connect to the database. This operation may take a few seconds if the database is paused. Please wait a moment...'):
        while True:
            try:
                cnxn = pyodbc.connect(
                    f'DRIVER={{ODBC Driver 17 for SQL Server}};'
                    f'SERVER={os.getenv("DB_SERVER")};'
                    f'DATABASE={os.getenv("DB_DATABASE")};'
                    f'UID={os.getenv("DB_UID")};'
                    f'PWD={os.getenv("DB_PWD")}',
                    timeout=5
                )
                return cnxn
            except pyodbc.OperationalError:
                print("Connection failed, retrying in 2 seconds...")
                time.sleep(2)

def get_embeddings(text):
    # Truncate the text to 8000 characters
    truncated_text = text[:8000]

    response = openai.Embedding.create(input=truncated_text, engine="embeddings")
    embeddings = response['data'][0]['embedding']
    return embeddings

# Streamlit app
def main():
    
    st.set_page_config(
        page_title="Leveraging KMeans Compute Node for Text Similarity Analysis through Vector Search in Azure SQL",
        page_icon="🧊",
        layout="wide",
        initial_sidebar_state="expanded",
    )


    with st.sidebar:
        st.image("https://miro.medium.com/v2/resize:fit:640/format:webp/1*BeqIgJHWNjBwIAjuUKQrig.png ")           
        ""
        "[Leveraging KMeans Compute Node for Text Similarity Analysis through Vector Search in Azure SQL](https://lawrence.eti.br/2024/02/25/leveraging-kmeans-compute-node-for-text-similarity-analysis-through-vector-search-in-azure-sql/)"
        "Combining vector databases with KMeans clustering revolutionizes the way applications suggest similar items, efficiently grouping and identifying related content, products, or articles. This powerful synergy enhances recommendation systems, offering personalized user experiences by leveraging the nuanced similarities within high-dimensional data."
        ""
        ""
        "Source: [Global News Dataset](https://www.kaggle.com/datasets/everydaycodings/global-news-dataset/)" 
        ""
        "Created by [Lawrence Teixeira](https://www.linkedin.com/in/lawrenceteixeira/)"
        ""
        "Please remember, this is merely a sample to illustrate the outcomes of a vector search with KMeans, as detailed in the preceding article."    
    
    st.title("Azure SQL for Vector Search Utilizing KMeans")

    # Text input for search query
    search_query = st.text_input("Type here your search:", placeholder="e.g., 'Generative AI: The Future Unveiled'")

    if st.button("Search"):
        # Connection to the database
        cnxn = get_connection()
        
        #vector = get_embeddings(search_query)
        
        # Definir a stored procedure e a consulta SQL
        stored_procedure = f"EXEC dbo.SearchNews_kmeans '{search_query}'"

        # Executar a stored procedure
        cnxn.execute(stored_procedure)
        
        query = "SELECT r.dot_product, r.published, r.category, r.title, r.author, r.full_content, r.url FROM result R order by r.dot_product DESC"

        # Executing the query
        with st.spinner('Executing the search...'):
            df = pd.read_sql(query, cnxn)

        # Displaying results
        if not df.empty:
            st.write("Search Results:")
            st.dataframe(df)
        else:
            st.write("No results found.")

if __name__ == "__main__":
    main()
