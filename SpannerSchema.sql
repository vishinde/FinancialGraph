-- -----------------------------------------------------------------------
-- FCloud Spanner (Transactional/Graph Layer) Setup
-- Purpose: Stores entities and relationships derived from unstructured reports 
--          (e.g., earnings calls, analyst reports).
-- -----------------------------------------------------------------------

-- A. Entity Table (Nodes)
-- Stores key players: Companies and People (Executives/Analysts).
CREATE TABLE Entities (
    EntityID STRING(36) NOT NULL,
    EntityType STRING(50) NOT NULL, -- 'COMPANY', 'PERSON'
    Name STRING(255) NOT NULL,
    Industry STRING(100),
    PRIMARY KEY (EntityID)
);

-- B. Relationship Table (Edges)
-- Stores connections between entities.
CREATE TABLE Relationships (
    SourceEntityID STRING(36) NOT NULL,
    TargetEntityID STRING(36) NOT NULL,
    RelationshipType STRING(50) NOT NULL, -- 'BOARD_MEMBER_OF', 'SUPPLIES', 'COMPETES_WITH'
    DateEstablished DATE,
    ReportSource STRING(255),
    PRIMARY KEY (SourceEntityID, TargetEntityID)
);

-- C. **NEW:** Document Vector Store (For RAG/Semantic Search)
CREATE TABLE FinancialDocuments (
    DocumentID STRING(36) NOT NULL,
    EntityID_Associated STRING(36) NOT NULL, -- Which entity does this report discuss?
    DocumentType STRING(50) NOT NULL, -- 'AnalystReport', 'Transcript', '10-K'
    TextContent STRING(MAX),
    -- Assuming a simplified 3-dimensional vector for demo
    VectorEmbedding ARRAY<FLOAT64>, 
    PRIMARY KEY (DocumentID)
);

-- D. Sample Graph Data Insertion

-- Entities
INSERT INTO Entities (EntityID, EntityType, Name, Industry) VALUES
('C100', 'COMPANY', 'GlobalTech Solutions', 'Technology'),
('C101', 'COMPANY', 'Innovate Finance Inc.', 'Finance'), -- Target Company
('C102', 'COMPANY', 'Competitor Robotics', 'Technology'),
('C103', 'COMPANY', 'Asia Manufacturing Corp.', 'Manufacturing'), -- New Supplier
('P200', 'PERSON', 'Jane Doe', 'Executive'),
('P201', 'PERSON', 'John Smith', 'Executive');

-- Relationships (Edges)
INSERT INTO Relationships (SourceEntityID, TargetEntityID, RelationshipType, DateEstablished, ReportSource) VALUES
('P200', 'C100', 'BOARD_MEMBER_OF', DATE '2020-01-01', 'SEC Report 2024'),
('C100', 'C101', 'SUPPLIES', DATE '2019-10-10', 'Earnings Call Transcript'),
('C103', 'C101', 'SUPPLIES', DATE '2023-08-01', 'Press Release'), -- NEW SUPPLIER
('C100', 'C102', 'COMPETES_WITH', DATE '2022-03-01', 'Risk Assessment 2023');

-- E. **NEW:** Sample Document Data Insertion
INSERT INTO FinancialDocuments (DocumentID, EntityID_Associated, DocumentType, TextContent, VectorEmbedding) VALUES
('D001', 'C100', 'AnalystReport', 'GlobalTech’s primary risk remains geopolitical uncertainty in the eastern markets, specifically concerning raw material inputs.', [0.8, 0.1, 0.1]), -- High geopolitical score
('D002', 'C103', 'AnalystReport', 'Asia Manufacturing Corp. is highly diversified and has minimal exposure to regional political conflicts.', [0.1, 0.9, 0.1]), -- Low geopolitical score
('D003', 'C101', 'Transcript', 'Innovate Finance discussed strong European growth but noted increased regulatory hurdles.', [0.3, 0.3, 0.5]);
