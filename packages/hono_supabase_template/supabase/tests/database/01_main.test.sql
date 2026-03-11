BEGIN;
SELECT plan(5);

SELECT has_table( 'users' );
SELECT has_column( 'users', 'id' );
SELECT has_column( 'users', 'auth_id' );
SELECT has_column( 'users', 'username' );

INSERT INTO auth.users (id, email) VALUES ('00000000-0000-0000-0000-ffffffffffff', 'trigger_test@example.com');

SELECT lives_ok(
  $$
    DO $body$
    DECLARE
      v_old_ts TIMESTAMPTZ;
      v_new_ts TIMESTAMPTZ;
    BEGIN
      SELECT updated_at INTO v_old_ts FROM public.users WHERE auth_id = '00000000-0000-0000-0000-ffffffffffff';
      PERFORM pg_sleep(0.001);
      UPDATE public.users SET username = 'trigger-test-updated' WHERE auth_id = '00000000-0000-0000-0000-ffffffffffff';
      SELECT updated_at INTO v_new_ts FROM public.users WHERE auth_id = '00000000-0000-0000-0000-ffffffffffff';
      IF v_new_ts <= v_old_ts THEN
        RAISE EXCEPTION 'updated_at was not refreshed: old=%, new=%', v_old_ts, v_new_ts;
      END IF;
    END $body$;
  $$,
  'updated_at trigger should auto-update on row modification'
);

SELECT * FROM finish();
ROLLBACK;
