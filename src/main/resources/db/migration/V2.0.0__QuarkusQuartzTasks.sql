DROP TABLE IF EXISTS QRTZ_FIRED_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_PAUSED_TRIGGER_GRPS;
DROP TABLE IF EXISTS QRTZ_SCHEDULER_STATE;
DROP TABLE IF EXISTS QRTZ_LOCKS;
DROP TABLE IF EXISTS QRTZ_SIMPLE_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_CRON_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_SIMPROP_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_BLOB_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_JOB_DETAILS;
DROP TABLE IF EXISTS QRTZ_CALENDARS;
DROP TABLE IF EXISTS TASKS;
DROP SEQUENCE IF EXISTS hibernate_sequence;

CREATE SEQUENCE hibernate_sequence start 1 increment 1;
CREATE TABLE tasks
(
    id int8 NOT NULL,
    createdAt TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE TABLE qrtz_job_details (
  sched_name        VARCHAR(120) NOT NULL,
  job_name          VARCHAR(200) NOT NULL,
  job_group         VARCHAR(200) NOT NULL,
    CONSTRAINT pkey_qrtz_job_details
      PRIMARY KEY (sched_name, job_name, job_group),
  description       VARCHAR(250) NULL,
  job_class_name    VARCHAR(250) NOT NULL,
  is_durable        BOOLEAN      NOT NULL,
  is_nonconcurrent  BOOLEAN      NOT NULL,
  is_update_data    BOOLEAN      NOT NULL,
  requests_recovery BOOLEAN      NOT NULL,
  job_data          BYTEA        NULL
);
CREATE INDEX idx_qrtz_job_details_sched_name_requests_recovery
  ON qrtz_job_details (sched_name, requests_recovery);
CREATE INDEX idx_qrtz_job_details_sched_name_job_group
  ON qrtz_job_details (sched_name, job_group);

CREATE TABLE qrtz_triggers (
  sched_name     VARCHAR(120) NOT NULL,
  trigger_name   VARCHAR(200) NOT NULL,
  trigger_group  VARCHAR(200) NOT NULL,
    CONSTRAINT pkey_qrtz_triggers
      PRIMARY KEY (sched_name, trigger_name, trigger_group),
  job_name       VARCHAR(200) NOT NULL,
  job_group      VARCHAR(200) NOT NULL,
    CONSTRAINT fkey_qrtz_triggers_qrtz_job_details
      FOREIGN KEY (sched_name, job_name, job_group)
        REFERENCES qrtz_job_details (sched_name, job_name, job_group),
  description    VARCHAR(250) NULL,
  next_fire_time BIGINT       NULL,
  prev_fire_time BIGINT       NULL,
  priority       INTEGER      NULL,
  trigger_state  VARCHAR(16)  NOT NULL,
  trigger_type   VARCHAR(8)   NOT NULL,
  start_time     BIGINT       NOT NULL,
  end_time       BIGINT       NULL,
  calendar_name  VARCHAR(200) NULL,
  misfire_instr  SMALLINT     NULL,
  job_data       BYTEA        NULL
);
CREATE INDEX idx_qrtz_triggers_sched_name_job_name_job_group
  ON qrtz_triggers (sched_name, job_name, job_group);
CREATE INDEX idx_qrtz_triggers_sched_name_job_group
  ON qrtz_triggers (sched_name, job_group);
CREATE INDEX idx_qrtz_triggers_sched_name_calendar_name
  ON qrtz_triggers (sched_name, calendar_name);
CREATE INDEX idx_qrtz_triggers_sched_name_trigger_group
  ON qrtz_triggers (sched_name, trigger_group);
CREATE INDEX idx_qrtz_triggers_sched_name_trigger_state
  ON qrtz_triggers (sched_name, trigger_state);
-- index name shortened due to 63 character constraint name limit
CREATE INDEX idx_qrtz_triggers_sched_name_trig_name_trig_group_trig_state
  ON qrtz_triggers (sched_name, trigger_name, trigger_group, trigger_state);
CREATE INDEX idx_qrtz_triggers_sched_name_trigger_group_trigger_state
  ON qrtz_triggers (sched_name, trigger_group, trigger_state);
CREATE INDEX idx_qrtz_triggers_sched_name_next_fire_time
  ON qrtz_triggers (sched_name, next_fire_time);
CREATE INDEX idx_qrtz_triggers_sched_name_trigger_state_next_fire_time
  ON qrtz_triggers (sched_name, trigger_state, next_fire_time);
CREATE INDEX idx_qrtz_triggers_sched_name_misfire_instr_next_fire_time
  ON qrtz_triggers (sched_name, misfire_instr, next_fire_time);
-- index name shortened due to 63 character constraint name limit
CREATE INDEX idx_qrtz_triggers_sched_name_mf_instr_next_f_time_trig_state
  ON qrtz_triggers (sched_name, misfire_instr, next_fire_time, trigger_state);
CREATE INDEX idx_qrtz_triggers_s_name_mf_instr_next_f_time_t_group_t_state
  ON qrtz_triggers (sched_name, misfire_instr, next_fire_time, trigger_group, trigger_state);

CREATE TABLE qrtz_simple_triggers (
  sched_name      VARCHAR(120) NOT NULL,
  trigger_name    VARCHAR(200) NOT NULL,
  trigger_group   VARCHAR(200) NOT NULL,
    CONSTRAINT pkey_qrtz_simple_triggers
      PRIMARY KEY (sched_name, trigger_name, trigger_group),
    CONSTRAINT fkey_qrtz_simple_triggers_qrtz_triggers
      FOREIGN KEY (sched_name, trigger_name, trigger_group)
        REFERENCES qrtz_triggers (sched_name, trigger_name, trigger_group),
  repeat_count    BIGINT       NOT NULL,
  repeat_interval BIGINT       NOT NULL,
  times_triggered BIGINT       NOT NULL
);

CREATE TABLE qrtz_cron_triggers (
  sched_name      VARCHAR(120) NOT NULL,
  trigger_name    VARCHAR(200) NOT NULL,
  trigger_group   VARCHAR(200) NOT NULL,
    CONSTRAINT pkey_qrtz_cron_triggers
      PRIMARY KEY (sched_name, trigger_name, trigger_group),
    CONSTRAINT fkey_qrtz_cron_triggers_qrtz_triggers
      FOREIGN KEY (sched_name, trigger_name, trigger_group)
        REFERENCES qrtz_triggers (sched_name, trigger_name, trigger_group),
  cron_expression VARCHAR(120) NOT NULL,
  time_zone_id    VARCHAR(80)
);

CREATE TABLE qrtz_simprop_triggers (
  sched_name    VARCHAR(120)   NOT NULL,
  trigger_name  VARCHAR(200)   NOT NULL,
  trigger_group VARCHAR(200)   NOT NULL,
    CONSTRAINT pkey_qrtz_simprop_triggers
      PRIMARY KEY (sched_name, trigger_name, trigger_group),
    CONSTRAINT fkey_qrtz_simprop_triggers_qrtz_triggers
      FOREIGN KEY (sched_name, trigger_name, trigger_group)
        REFERENCES qrtz_triggers (sched_name, trigger_name, trigger_group),
  str_prop_1    VARCHAR(512)   NULL,
  str_prop_2    VARCHAR(512)   NULL,
  str_prop_3    VARCHAR(512)   NULL,
  int_prop_1    INTEGER            NULL,
  int_prop_2    INTEGER            NULL,
  long_prop_1   BIGINT         NULL,
  long_prop_2   BIGINT         NULL,
  dec_prop_1    NUMERIC(13, 4) NULL,
  dec_prop_2    NUMERIC(13, 4) NULL,
  boolean_prop_1   BOOLEAN     NULL,
  boolean_prop_2   BOOLEAN     NULL
);

CREATE TABLE qrtz_blob_triggers (
  sched_name    VARCHAR(120) NOT NULL,
  trigger_name  VARCHAR(200) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
    CONSTRAINT pkey_qrtz_blob_triggers
      PRIMARY KEY (sched_name, trigger_name, trigger_group),
    CONSTRAINT fkey_qrtz_blob_triggers_qrtz_triggers
      FOREIGN KEY (sched_name, trigger_name, trigger_group)
        REFERENCES qrtz_triggers (sched_name, trigger_name, trigger_group),
  blob_data     BYTEA        NULL
);

CREATE TABLE qrtz_calendars (
  sched_name    VARCHAR(120) NOT NULL,
  calendar_name VARCHAR(200) NOT NULL,
    CONSTRAINT pkey_qrtz_calendars
      PRIMARY KEY (sched_name, calendar_name),
  calendar      BYTEA        NOT NULL
);


CREATE TABLE qrtz_paused_trigger_grps (
  sched_name    VARCHAR(120) NOT NULL,
  trigger_group VARCHAR(200) NOT NULL,
    CONSTRAINT pkey_qrtz_paused_trigger_grps
      PRIMARY KEY (sched_name, trigger_group)
);

CREATE TABLE qrtz_fired_triggers (
  sched_name        VARCHAR(120) NOT NULL,
  entry_id          VARCHAR(95)  NOT NULL,
    CONSTRAINT pkey_qrtz_fired_triggers
      PRIMARY KEY (sched_name, entry_id),
  trigger_name      VARCHAR(200) NOT NULL,
  trigger_group     VARCHAR(200) NOT NULL,
  instance_name     VARCHAR(200) NOT NULL,
  fired_time        BIGINT       NOT NULL,
  sched_time        BIGINT       NOT NULL,
  priority          INTEGER      NOT NULL,
  state             VARCHAR(16)  NOT NULL,
  job_name          VARCHAR(200) NULL,
  job_group         VARCHAR(200) NULL,
  is_nonconcurrent  BOOLEAN      NULL,
  requests_recovery BOOLEAN      NULL
);
CREATE INDEX idx_qrtz_fired_triggers_sched_name_instance_name
  ON qrtz_fired_triggers (sched_name, instance_name);
  -- index name shortened due to 63 character constraint name limit
CREATE INDEX idx_qrtz_fired_triggers_sched_name_instance_name_reqs_recovery
  ON qrtz_fired_triggers (sched_name, instance_name, requests_recovery);
CREATE INDEX idx_qrtz_fired_triggers_sched_name_job_name_job_group
  ON qrtz_fired_triggers (sched_name, job_name, job_group);
CREATE INDEX idx_qrtz_fired_triggers_sched_name_job_group
  ON qrtz_fired_triggers (sched_name, job_group);
CREATE INDEX idx_qrtz_fired_triggers_sched_name_trigger_name_trigger_group
  ON qrtz_fired_triggers (sched_name, trigger_name, trigger_group);
CREATE INDEX idx_qrtz_fired_triggers_sched_name_trigger_group
  ON qrtz_fired_triggers (sched_name, trigger_group);

CREATE TABLE qrtz_scheduler_state (
  sched_name        VARCHAR(120) NOT NULL,
  instance_name     VARCHAR(200) NOT NULL,
    CONSTRAINT pkey_qrtz_scheduler_state
      PRIMARY KEY (sched_name, instance_name),
  last_checkin_time BIGINT       NOT NULL,
  checkin_interval  BIGINT       NOT NULL
);

CREATE TABLE qrtz_locks (
  sched_name VARCHAR(120) NOT NULL,
  lock_name  VARCHAR(40)  NOT NULL,
    CONSTRAINT pkey_qrtz_locks
      PRIMARY KEY (sched_name, lock_name)
);
