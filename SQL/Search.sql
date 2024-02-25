/*
    This SQL code is used to search for similar news articles based on a given input using vector embeddings.
    It makes use of an external REST endpoint to retrieve the embeddings for the input text.
    The code then calls the 'find_similar$news$content_vector' function to find the top 10 similar news articles.
    The similarity is calculated based on the dot product of the embeddings.
    The result is ordered by the dot product in descending order.
*/

-- FILEPATH: /d:/Code/Vector_KMeans/SQL/Search.sql
declare @response nvarchar(max);
declare @payload nvarchar(max) = json_object('input': 'The future of Generative AI is here.');

exec sp_invoke_external_rest_endpoint
    @url = 'https://<YOUR APP>.openai.azure.com/openai/deployments/embeddings/embeddings?api-version=2023-03-15-preview',
    @credential = [https://<YOUR APP>.openai.azure.com],
    @payload = @payload,
    @response = @response output;

select top 10 r.published, r.category, r.author, r.title, r.content, r.dot_product
from [$vector].find_similar$news$content_vector(json_query(@response, '$.result.data[0].embedding'), 50, 0.80)  AS r
order by dot_product desc
