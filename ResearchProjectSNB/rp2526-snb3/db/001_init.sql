-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Images table
CREATE TABLE images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  original_path TEXT NOT NULL,
  processed_path TEXT,
  sha256 CHAR(64) NOT NULL,
  mime TEXT NOT NULL CHECK (mime IN ('image/jpeg', 'image/png', 'image/webp')),
  bytes INTEGER NOT NULL CHECK (bytes > 0),
  status TEXT NOT NULL DEFAULT 'uploaded' CHECK (status IN ('uploaded', 'queued', 'processing', 'done', 'failed')),
  processing_options JSONB DEFAULT '{"method": "mosaic", "scale_720p": false, "mosaic_size": 20}',
  user_id TEXT NOT NULL DEFAULT 'shared',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Jobs queue table
CREATE TABLE jobs (
  id BIGSERIAL PRIMARY KEY,
  image_id UUID NOT NULL REFERENCES images(id) ON DELETE CASCADE,
  kind TEXT NOT NULL DEFAULT 'deface_boxes',
  status TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'processing', 'done', 'failed')),
  run_at TIMESTAMPTZ DEFAULT NOW(),
  attempts INTEGER DEFAULT 0,
  claimed_by TEXT,
  claimed_at TIMESTAMPTZ,
  dedupe_key TEXT UNIQUE,
  error_log TEXT,
  processing_options JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Events audit table
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  image_id UUID NOT NULL REFERENCES images(id) ON DELETE CASCADE,
  at TIMESTAMPTZ DEFAULT NOW(),
  type TEXT NOT NULL,
  data JSONB DEFAULT '{}'
);

-- Indexes for performance
CREATE INDEX idx_jobs_queue ON jobs(status, run_at) WHERE status = 'queued';
CREATE INDEX idx_jobs_processing ON jobs(status, claimed_at) WHERE status = 'processing';
CREATE INDEX idx_images_status ON images(status);
CREATE INDEX idx_images_sha256 ON images(sha256);
CREATE INDEX idx_images_user_id ON images(user_id);
CREATE INDEX idx_images_user_status_created ON images(user_id, status, created_at DESC);
CREATE INDEX idx_events_image_id ON events(image_id);
CREATE INDEX idx_events_at ON events(at DESC);

-- Update trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER images_updated_at BEFORE UPDATE ON images
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER jobs_updated_at BEFORE UPDATE ON jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Notify function for job queue
CREATE OR REPLACE FUNCTION notify_job_queued()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('jobs_channel', json_build_object(
    'id', NEW.id,
    'image_id', NEW.image_id,
    'kind', NEW.kind
  )::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER jobs_notify_queued AFTER INSERT ON jobs
  FOR EACH ROW WHEN (NEW.status = 'queued')
  EXECUTE FUNCTION notify_job_queued();
