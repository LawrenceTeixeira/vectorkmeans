/*
    This selection of SQL code performs the following tasks:

    1. Creates a temporary table #trab1 and inserts all rows from the 'news' table where the 'title_vector' column is not null.
    2. Selects the 'article_id' as 'item_id', 'key' as 'vector_value_id', and 'value' as 'vector_value' from the temporary table #trab1.
    3. Inserts the selected values into the [dbo].[news$content_vector] table.
    4. Uses the OPENJSON function to parse the 'content_vector' column from the #trab1 table.
    5. Creates a clustered columnstore index named 'ixcc' on the [dbo].[news$content_vector] table, with the columns 'item_id' and 'vector_value_id' as the ordering columns.
    6. Drops the temporary table #trab1.

    This code is used to create a support table for performing vector-based operations on news articles.
*/
select * into #trab1 from news where title_vector is not null

select 
    article_id as item_id,
    cast([key] as int) as [vector_value_id],
    cast([value] as float) as [vector_value]
into 
    [dbo].[news$content_vector]
from
    #trab1
cross apply
    openjson([content_vector])    
go 

/*
    Create clustered columnstore index
*/
create clustered columnstore index ixcc 
on [dbo].[news$content_vector] order (item_id, vector_value_id) 
with (maxdop = 1)        
go

drop table #trab1