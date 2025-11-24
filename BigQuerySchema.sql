-- -----------------------------------------------------------------------
-- BigQuery (Analytical) Setup
-- Purpose: Stores historical financial data, revenue, and projections.
-- -----------------------------------------------------------------------

-- NOTE: Replace 'your_project.your_dataset' with your actual BQ location.

CREATE TABLE IF NOT EXISTS `your_project.your_dataset.financial_metrics_yoy` (
    entity_id STRING(36) NOT NULL,
    metric_date DATE NOT NULL,
    metric_type STRING(50) NOT NULL, -- 'Revenue', 'EBITDA', 'StockPrice'
    metric_value NUMERIC,
    geopolitical_risk_score FLOAT64, -- Feature derived from BQ ML/NLP analysis
    PRIMARY KEY (entity_id, metric_date, metric_type) NOT ENFORCED
);

-- Sample Data Insertion
INSERT INTO `your_project.your_dataset.financial_metrics_yoy` 
(entity_id, metric_date, metric_type, metric_value, geopolitical_risk_score)
VALUES
('C100', '2024-12-31', 'Revenue', 50000000.00, 0.2),
('C100', '2023-12-31', 'Revenue', 45000000.00, 0.1),
('C101', '2024-12-31', 'Revenue', 15000000.00, 0.6), -- Higher risk score
('C102', '2024-12-31', 'Revenue', 30000000.00, 0.2);
