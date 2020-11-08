CREATE OR REPLACE PROCEDURE @DATASET_NAME.sp_ExractEmbeddings() 
BEGIN
  CREATE OR REPLACE TABLE  @DATASET_NAME.item_embeddings AS
    WITH 
    step1 AS
    (
        SELECT 
            feature AS item_Id,
            factor_weights,
        FROM
            ML.WEIGHTS(MODEL `@DATASET_NAME.item_matching_model`)
        WHERE feature != 'global__INTERCEPT__'
    ),

    step2 AS
    (
        SELECT 
            item_Id, 
            factor, 
            SUM(weight) weight
        FROM step1,
        UNNEST(step1.factor_weights) AS embedding
        GROUP BY 
        item_Id,
        factor 
    )

    SELECT 
        item_Id, 
        ARRAY_AGG(weight ORDER BY factor ASC) embedding
    FROM step2
    GROUP BY item_Id;
END