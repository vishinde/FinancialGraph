-- -----------------------------------------------------------------------
-- BigQuery Federated Query - Semantic Graph Search Augmentation
-- Purpose: Find suppliers to C101 and filter by semantic risk (vector similarity).
-- -----------------------------------------------------------------------


-- Assume a query vector for "geopolitical uncertainty" is [0.85, 0.1, 0.08]

SELECT
    Supplier_Info.Supplier_Name,
    Supplier_Info.DocumentType,
    Supplier_Info.Similarity_Score, -- Vector similarity score from Spanner
    BQ_Metrics.metric_value AS Latest_Revenue_USD,
    BQ_Metrics.geopolitical_risk_score AS BQ_Analytic_Risk
FROM
    -- 1. BIGQUERY: Select Historical Metrics
    `your_project.your_dataset.financial_metrics_yoy` AS BQ_Metrics
INNER JOIN
    -- 2. FEDERATED QUERY: Perform 1-hop traversal (SUPPLIES) AND a Vector Search
    EXTERNAL_QUERY(
        'us-central1.spanner-connection', -- Replace with your Spanner Connection ID
        '''
        -- Spanner SQL: Find suppliers and their related documents/vectors
        SELECT 
            Supplier_Entity.EntityID, 
            Supplier_Entity.Name AS Supplier_Name,
            Docs.DocumentType,
            -- Calculate Vector Similarity (Simplified function for demo)
            1 - COSINE_DISTANCE(Docs.VectorEmbedding, ARRAY<FLOAT64>[0.85, 0.1, 0.08]) AS Similarity_Score
        FROM 
            Relationships AS Rel
        INNER JOIN
            Entities AS Supplier_Entity
        ON Rel.SourceEntityID = Supplier_Entity.EntityID
        INNER JOIN
            FinancialDocuments AS Docs
        ON Supplier_Entity.EntityID = Docs.EntityID_Associated
        WHERE 
            Rel.TargetEntityID = 'C101' AND -- Target Company: Innovate Finance Inc.
            Rel.RelationshipType = 'SUPPLIES'
        HAVING 
            Similarity_Score > 0.7 -- Semantic Filter: Only include reports highly similar to "geopolitical risk"
        '''
    ) AS Supplier_Info
    ON BQ_Metrics.entity_id = Supplier_Info.EntityID
WHERE
    BQ_Metrics.metric_type = 'Revenue' AND BQ_Metrics.metric_date = DATE '2024-12-31';

-- -----------------------------------------------------------------------
-- BigQuery Federated Query - Hybrid Graph Analysis
-- Purpose: Find entities related via graph traversal (Spanner) and augment 
--          with financial context (BigQuery).
-- -----------------------------------------------------------------------

SELECT
    Relationship_Info.Competitor_Name, -- This is now fetched directly from Spanner
    Relationship_Info.Industry,        -- This is now fetched directly from Spanner
    -- Analytical Data from BigQuery
    BQ_Metrics.metric_value AS Latest_Revenue_USD,
    BQ_Metrics.geopolitical_risk_score,
    Relationship_Info.RelationshipType,
    Relationship_Info.Overlapping_Executive_Name -- This is now fetched directly from Spanner
FROM
    -- 1. BIGQUERY: Select Historical Metrics and Filter by Metric Type
    `my-alloydb-project-vivekshinde.historical_finance.financial_metrics_yoy` AS BQ_Metrics
INNER JOIN
    -- 2. FEDERATED QUERY: Perform a 2-hop graph traversal in Spanner (Global) and lookup the Names
    EXTERNAL_QUERY(
        'us-central1.spanner-connection', -- Replace with your Spanner Connection ID
        '''
        -- Spanner SQL: Find connected entities and immediately lookup their names
        SELECT 
            Related_Company.EntityID AS TargetEntityID, -- Used for the join back to BQ_Metrics
            Related_Company.Name AS Competitor_Name,    -- Name fetched from Spanner
            Related_Company.Industry,                   -- Industry fetched from Spanner
            t2.RelationshipType, 
            Related_Executive.Name AS Overlapping_Executive_Name
        FROM 
            Relationships AS t2
        INNER JOIN 
            Relationships AS t1
        ON t2.SourceEntityID = t1.SourceEntityID -- Connects Jane Doe (SourceEntityID) to both companies
        INNER JOIN 
            Entities AS Related_Company
        ON t2.TargetEntityID = Related_Company.EntityID -- Lookup Target Company details
        INNER JOIN 
            Entities AS Related_Executive
        ON t1.SourceEntityID = Related_Executive.EntityID -- Lookup Executive name
        WHERE 
            t1.TargetEntityID = 'C101' AND 
            t2.TargetEntityID != 'C101' AND 
            t2.RelationshipType = 'BOARD_MEMBER_OF'
        '''
    ) AS Relationship_Info
    ON BQ_Metrics.entity_id = Relationship_Info.TargetEntityID -- Join on EntityID
WHERE
    BQ_Metrics.metric_type = 'Revenue' AND BQ_Metrics.metric_date = DATE '2024-12-31';
