-- This file runs on first database initialization

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set default permissions
GRANT ALL PRIVILEGES ON DATABASE iam_db TO iam_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO iam_user;

-- Ensure user has all necessary privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO iam_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO iam_user;

-- Log initialization
DO $$
BEGIN
    RAISE NOTICE 'Database initialized successfully';
END $$;