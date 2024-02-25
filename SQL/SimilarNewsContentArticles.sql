/*
    FILEPATH: /d:/Code/Vector_KMeans/SQL/SimilarNewsContentArticles.sql

    This script defines a user-defined function named [$vector].[find_similar$news$content_vector].
    The function takes three parameters: @vector (nvarchar(max)), @probe (int), and @similarity (float).
    It returns a table with the following columns:
    - id: The item ID of the similar news content.
    - dot_product: The dot product value representing the similarity between the input vector and the news content vector.

    The function performs the following steps:
    1. Parses the input @vector using the OPENJSON function and stores the vector values in the cteVectorInput common table expression.
    2. Calculates the dot product between the input vector and the centroids of the news content clusters in the cteCentroids common table expression.
    3. Retrieves the news content vectors that belong to the top @probe clusters with the highest dot product values in the cteVectorContent common table expression.
    4. Calculates the dot product between the input vector and the retrieved news content vectors in the cteIds common table expression.
    5. Joins the cteIds table with the [dbo].[news] table to retrieve the corresponding news records.
    6. Filters the result based on the dot_product value being greater than the @similarity threshold.

    Example usage:
    SELECT *
    FROM [$vector].[find_similar$news$content_vector]('{"1": 0.5, "2": 0.3, "3": 0.2}', 5, 0.8);

    This will return the news records that have a similarity greater than 0.8 with the input vector.

*/
/****** Object:  UserDefinedFunction [$vector].[find_similar$news$content_vector]    Script Date: 2/25/2024 5:18:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

        ALTER   function [$vector].[find_similar$news$content_vector] (@vector nvarchar(max), @probe int, @similarity float)
        returns table
        as return
        with cteVectorInput as
        (
            select 
                cast([key] as smallint) as vector_value_id, 
                cast([value] as float) as vector_value
            from
                openjson(@vector) as t
        ),
        cteCentroids as
        (
            select 
                v2.cluster_id, 
                sum(v1.[vector_value] * v2.[vector_value]) as dot_product              
            from 
                cteVectorInput v1
            inner join 
                [$vector].[news$content_vector$clusters_centroids] v2 on v1.vector_value_id = v2.vector_value_id
            group by
                v2.cluster_id
        ),
        cteVectorContent as
        (
            select 
                e.item_id as id,
                vector_value_id, 
                vector_value
            from 
                [dbo].[news$content_vector] e
            inner join 
                [$vector].[news$content_vector$clusters] c on e.item_id = c.item_id
            where
                c.cluster_id in (select top(@probe) cluster_id from cteCentroids order by dot_product desc)
        ), 
        cteIds as 
        (
            select
                v2.id, 
                sum(v1.[vector_value] * v2.[vector_value]) as dot_product              
            from 
                cteVectorInput v1
            inner join 
                cteVectorContent v2 on v1.vector_value_id = v2.vector_value_id
            group by
                v2.id
        )
        select
            a.*, c.dot_product
        from
            cteIds c
        inner join  
            [dbo].[news] a on c.id = a.id
        where 
            dot_product > @similarity;
        