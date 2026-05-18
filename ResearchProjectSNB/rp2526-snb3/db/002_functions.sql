-- Function to claim jobs atomically
CREATE OR REPLACE FUNCTION claim_jobs(
  worker_id TEXT,
  batch_size INTEGER DEFAULT 1
)
RETURNS TABLE (
  id BIGINT,
  image_id UUID,
  kind TEXT,
  attempts INTEGER
) AS $$
DECLARE
  claimed_job_ids BIGINT[];
BEGIN
  -- Claim jobs and get their IDs
  WITH claimed AS (
    UPDATE jobs
    SET 
      status = 'processing',
      claimed_by = worker_id,
      claimed_at = NOW(),
      attempts = jobs.attempts + 1
    WHERE jobs.id IN (
      SELECT jobs.id
      FROM jobs
      WHERE jobs.status = 'queued'
        AND jobs.run_at <= NOW()
      ORDER BY jobs.run_at
      FOR UPDATE SKIP LOCKED
      LIMIT batch_size
    )
    RETURNING jobs.id, jobs.image_id, jobs.kind, jobs.attempts
  )
  SELECT array_agg(c.id) INTO claimed_job_ids FROM claimed c;

  -- Update corresponding images to processing status
  UPDATE images 
  SET status = 'processing'
  WHERE images.id IN (
    SELECT DISTINCT j.image_id 
    FROM jobs j
    WHERE j.id = ANY(claimed_job_ids)
  );

  -- Return the claimed jobs
  RETURN QUERY
  SELECT j.id, j.image_id, j.kind, j.attempts
  FROM jobs j
  WHERE j.id = ANY(claimed_job_ids);
END;
$$ LANGUAGE plpgsql;

-- Function to complete a job
CREATE OR REPLACE FUNCTION complete_job(
  job_id BIGINT,
  p_processed_path TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_image_id UUID;
BEGIN
  -- Update job status
  UPDATE jobs
  SET status = 'done'
  WHERE id = job_id
  RETURNING image_id INTO v_image_id;
  
  IF v_image_id IS NULL THEN
    RETURN FALSE;
  END IF;
  
  -- Update image if processed path provided
  IF p_processed_path IS NOT NULL THEN
    UPDATE images
    SET 
      status = 'done',
      processed_path = p_processed_path
    WHERE id = v_image_id;
  END IF;
  
  -- Log event
  INSERT INTO events (image_id, type, data)
  VALUES (
    v_image_id, 
    'job_completed',
    jsonb_build_object('job_id', job_id, 'processed_path', p_processed_path)
  );
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to fail a job with retry logic
CREATE OR REPLACE FUNCTION fail_job(
  job_id BIGINT,
  error_message TEXT,
  max_attempts INTEGER DEFAULT 3
)
RETURNS TEXT AS $$
DECLARE
  v_attempts INTEGER;
  v_image_id UUID;
  v_status TEXT;
BEGIN
  SELECT attempts, image_id 
  INTO v_attempts, v_image_id
  FROM jobs 
  WHERE id = job_id;
  
  IF v_attempts >= max_attempts THEN
    -- Final failure
    UPDATE jobs
    SET 
      status = 'failed',
      error_log = error_message
    WHERE id = job_id;
    
    UPDATE images
    SET status = 'failed'
    WHERE id = v_image_id;
    
    v_status := 'failed';
  ELSE
    -- Retry with exponential backoff
    UPDATE jobs
    SET 
      status = 'queued',
      run_at = NOW() + (v_attempts * interval '10 seconds'),
      error_log = error_message,
      claimed_by = NULL,
      claimed_at = NULL
    WHERE id = job_id;
    
    v_status := 'retry';
  END IF;
  
  -- Log event
  INSERT INTO events (image_id, type, data)
  VALUES (
    v_image_id,
    'job_' || v_status,
    jsonb_build_object(
      'job_id', job_id,
      'attempts', v_attempts,
      'error', error_message
    )
  );
  
  RETURN v_status;
END;
$$ LANGUAGE plpgsql;

-- Function to get queue stats
CREATE OR REPLACE FUNCTION get_queue_stats()
RETURNS TABLE (
  status TEXT,
  count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT jobs.status, COUNT(*)
  FROM jobs
  WHERE jobs.created_at > NOW() - interval '24 hours'
  GROUP BY jobs.status;
END;
$$ LANGUAGE plpgsql;
