-- Rate limiting for generate-image Edge Function
-- Sliding window: max N requests per user per time window

CREATE TABLE IF NOT EXISTS generation_rate_limits (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    window_start TIMESTAMPTZ NOT NULL DEFAULT now(),
    request_count INT NOT NULL DEFAULT 1
);

-- RLS: service_role only (no authenticated access)
ALTER TABLE generation_rate_limits ENABLE ROW LEVEL SECURITY;

-- Rate limit check function
-- Returns JSON: {allowed: bool, remaining: int, retry_after?: int}
CREATE OR REPLACE FUNCTION check_rate_limit(
    p_user_id UUID,
    p_max_requests INT DEFAULT 5,
    p_window_seconds INT DEFAULT 60
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_row generation_rate_limits%ROWTYPE;
    v_now TIMESTAMPTZ := now();
    v_window_age FLOAT;
    v_remaining INT;
BEGIN
    -- Try to get existing row
    SELECT * INTO v_row
    FROM generation_rate_limits
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        -- First request ever: insert and allow
        INSERT INTO generation_rate_limits (user_id, window_start, request_count)
        VALUES (p_user_id, v_now, 1);
        RETURN jsonb_build_object(
            'allowed', true,
            'remaining', p_max_requests - 1
        );
    END IF;

    -- Calculate window age in seconds
    v_window_age := EXTRACT(EPOCH FROM (v_now - v_row.window_start));

    IF v_window_age >= p_window_seconds THEN
        -- Window expired: reset
        UPDATE generation_rate_limits
        SET window_start = v_now, request_count = 1
        WHERE user_id = p_user_id;
        RETURN jsonb_build_object(
            'allowed', true,
            'remaining', p_max_requests - 1
        );
    END IF;

    IF v_row.request_count >= p_max_requests THEN
        -- At limit: deny
        RETURN jsonb_build_object(
            'allowed', false,
            'remaining', 0,
            'retry_after', CEIL(p_window_seconds - v_window_age)::INT
        );
    END IF;

    -- Within window, under limit: increment
    UPDATE generation_rate_limits
    SET request_count = request_count + 1
    WHERE user_id = p_user_id;

    v_remaining := p_max_requests - v_row.request_count - 1;
    RETURN jsonb_build_object(
        'allowed', true,
        'remaining', v_remaining
    );
END;
$$;

-- Revoke from authenticated — only service_role can call
REVOKE EXECUTE ON FUNCTION check_rate_limit FROM authenticated;
REVOKE EXECUTE ON FUNCTION check_rate_limit FROM anon;
