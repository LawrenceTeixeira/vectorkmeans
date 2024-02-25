/*
    Stored Procedure: [dbo].[SearchNews_kmeans]
    Description: This stored procedure is used to search for similar news articles based on a given input text using the K-means algorithm.
    Parameters:
        - @inputText: The input text used for searching similar news articles.
    Returns: None
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SearchNews_kmeans] 
    @inputText NVARCHAR(MAX)
AS
BEGIN
    -- Declare necessary variables
    DECLARE @response NVARCHAR(MAX);
    DECLARE @payload NVARCHAR(MAX);
    DECLARE @url NVARCHAR(MAX) = 'https://<YOUR APP>.openai.azure.com/openai/deployments/embeddings/embeddings?api-version=2023-03-15-preview';

    -- Construct the payload
    SET @payload = json_object('input': @inputText);

    -- Call the external REST endpoint
    EXEC sp_invoke_external_rest_endpoint
        @url = @url,
        @credential = [https://<YOUR APP>.openai.azure.com],
        @payload = @payload,
        @response = @response OUTPUT;

    -- Query the SimilarNewsContentArticles table using the response
    IF OBJECT_ID('dbo.result', 'U') IS NOT NULL
        DROP TABLE dbo.result;

    SELECT TOP (10) *
    INTO result
    FROM  [$vector].find_similar$news$content_vector(json_query(@response, '$.result.data[0].embedding'), 2, 0.75) 
    ORDER BY dot_product DESC;
END
