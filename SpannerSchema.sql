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

-- C. Sample Graph Data Insertion

-- Entities
INSERT INTO Entities (EntityID, EntityType, Name, Industry) VALUES
('C100', 'COMPANY', 'GlobalTech Solutions', 'Technology'),
('C101', 'COMPANY', 'Innovate Finance Inc.', 'Finance'),
('C102', 'COMPANY', 'Competitor Robotics', 'Technology'),
('P200', 'PERSON', 'Jane Doe', 'Executive'),
('P201', 'PERSON', 'John Smith', 'Executive');

-- Relationships (Edges)
INSERT INTO Relationships (SourceEntityID, TargetEntityID, RelationshipType, DateEstablished, ReportSource) VALUES
-- Overlapping Board Member: Jane Doe is on the board of GlobalTech and Innovate Finance
('P200', 'C100', 'BOARD_MEMBER_OF', DATE '2020-01-01', 'SEC Report 2024'),
('P200', 'C101', 'BOARD_MEMBER_OF', DATE '2021-05-15', 'Analyst Report Q1'),
-- Supply Chain Dependency: GlobalTech is a supplier to Innovate Finance
('C100', 'C101', 'SUPPLIES', DATE '2019-10-10', 'Earnings Call Transcript'),
-- Competitive Relationship
('C100', 'C102', 'COMPETES_WITH', DATE '2022-03-01', 'Risk Assessment 2023');
