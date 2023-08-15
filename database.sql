CREATE TABLE IF NOT EXISTS public.admin
(
    sno serial not null,
    admin_id character varying(8) COLLATE pg_catalog."default" NOT NULL,
    admin_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    admin_passwd character varying(20) COLLATE pg_catalog."default" NOT NULL,
    admin_cont character varying(10) COLLATE pg_catalog."default",
    CONSTRAINT admin_pkey PRIMARY KEY (admin_id),
    CONSTRAINT contact_cons1 CHECK (admin_cont::text !~~ '0%'::text),
    CONSTRAINT cooo CHECK (admin_cont::text ~~ '__________'::text)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.admin
    OWNER to postgres;


-- Table: public.warden

-- DROP TABLE IF EXISTS public.warden;

CREATE TABLE IF NOT EXISTS public.warden
(
    sno serial NOT NULL ,
    warden_id character varying(8) COLLATE pg_catalog."default" NOT NULL,
    warden_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    warden_passwd character varying(20) COLLATE pg_catalog."default" NOT NULL,
    warden_cont character varying(10) COLLATE pg_catalog."default",
    CONSTRAINT warden_pkey PRIMARY KEY (warden_id),
    CONSTRAINT contact_cons1 CHECK (warden_cont::text !~~ '0%'::text),
    CONSTRAINT co CHECK (warden_cont::text ~~ '__________'::text)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.warden
    OWNER to postgres;

-- Table: public.hostel

-- DROP TABLE IF EXISTS public.hostel;

CREATE TABLE IF NOT EXISTS public.hostel
(
    hostel_id character varying(8) COLLATE pg_catalog."default" NOT NULL,
    hostel_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    hostel_cont character varying(10) COLLATE pg_catalog."default",
    warden_ref_id character varying(8) COLLATE pg_catalog."default",
    CONSTRAINT hostel_pkey PRIMARY KEY (hostel_id),
    CONSTRAINT hostel_warden_ref_id_fkey FOREIGN KEY (warden_ref_id)
        REFERENCES public.warden (warden_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT cooo CHECK (hostel_cont::text ~~ '__________'::text)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.hostel
    OWNER to postgres;

-- Table: public.student

-- DROP TABLE IF EXISTS public.student;

CREATE TABLE IF NOT EXISTS public.student
(
    student_id character varying(8) COLLATE pg_catalog."default" NOT NULL,
    student_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    student_passwd character varying(20) COLLATE pg_catalog."default" NOT NULL,
    student_gender character varying(1) COLLATE pg_catalog."default",
    student_cont character varying(10) COLLATE pg_catalog."default",
    hostel_ref_id character varying(8) COLLATE pg_catalog."default",
    room_no integer NOT NULL,
    email character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT student_pkey PRIMARY KEY (student_id),
    CONSTRAINT student_hostel_ref_id_fkey FOREIGN KEY (hostel_ref_id)
        REFERENCES public.hostel (hostel_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT student_student_gender_check CHECK (student_gender::text = ANY (ARRAY['M'::character varying, 'F'::character varying]::text[])),
    CONSTRAINT contact_cons1 CHECK (student_cont::text !~~ '0%'::text),
    CONSTRAINT coo CHECK (student_cont::text ~~ '__________'::text)
)

-- Table: public.complaints

-- DROP TABLE IF EXISTS public.complaints;

CREATE TABLE IF NOT EXISTS public.complaints
(
    complaint_id serial NOT NULL,
    category character varying(20) COLLATE pg_catalog."default",
    description character varying(200) COLLATE pg_catalog."default",
    student_ref_id character varying(8) COLLATE pg_catalog."default",
    hostel_ref_id character varying(8) COLLATE pg_catalog."default",
    status character varying(20) COLLATE pg_catalog."default",
    title character varying(100) COLLATE pg_catalog."default",
    room_no integer,
    auth character varying(8) COLLATE pg_catalog."default",
    ack character varying(20) COLLATE pg_catalog."default",
    "time" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT complaints_pkey PRIMARY KEY (complaint_id),
    CONSTRAINT complaints_hostel_ref_id_fkey FOREIGN KEY (hostel_ref_id)
        REFERENCES public.hostel (hostel_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT complaints_student_ref_id_fkey FOREIGN KEY (student_ref_id)
        REFERENCES public.student (student_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT complaints_category_check CHECK (category::text = ANY (ARRAY['Electricity'::character varying, 'Water'::character varying, 'Food'::character varying, 'Hygiene'::character varying]::text[])),
    CONSTRAINT complaints_auth_check CHECK (auth::text = ANY (ARRAY['Admin'::character varying, 'Warden'::character varying]::text[])),
    CONSTRAINT complaints_ack_check CHECK (ack::text = ANY (ARRAY['Yes'::character varying, 'No'::character varying]::text[]))
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.complaints
    OWNER to postgres;

-- Table: public.notice

-- DROP TABLE IF EXISTS public.notice;

CREATE TABLE IF NOT EXISTS public.notice
(
    description character varying(100) COLLATE pg_catalog."default",
    owner character varying(20) COLLATE pg_catalog."default",
    dateofnotice timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notice_id integer NOT NULL DEFAULT nextval('notice_notice_id_seq'::regclass),
    CONSTRAINT notice_pkey PRIMARY KEY (notice_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.notice
    OWNER to postgres;


-- Table: public.utility

-- DROP TABLE IF EXISTS public.utility;

CREATE TABLE IF NOT EXISTS public.utility
(
    id integer NOT NULL DEFAULT nextval('utility_id_seq'::regclass),
    category character varying(20) COLLATE pg_catalog."default",
    name character varying(20) COLLATE pg_catalog."default",
    email character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT utility_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.utility
    OWNER to postgres;

-- PROCEDURE: public.auto_esc()

-- DROP PROCEDURE IF EXISTS public.auto_esc();

CREATE OR REPLACE PROCEDURE public.auto_esc(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    update complaints
    set auth = 'Admin',status ='Pending'
    where DATE_PART('day', current_timestamp - time)>7 and status='Solved';
END; 
$BODY$;
ALTER PROCEDURE public.auto_esc()
    OWNER TO postgres;