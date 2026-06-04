--
-- PostgreSQL database dump
--

\restrict kcDbqXNKuAazUSPrPQK3EGvI1FoSaLebonZhaRtLuCe5hr2zW4XmZuedZbyhjq3

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-06-05 02:04:32

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 49342)
-- Name: contact_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contact_types (
    id integer NOT NULL,
    type_name character varying(50) NOT NULL
);


ALTER TABLE public.contact_types OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 49341)
-- Name: contact_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contact_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contact_types_id_seq OWNER TO postgres;

--
-- TOC entry 4928 (class 0 OID 0)
-- Dependencies: 219
-- Name: contact_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contact_types_id_seq OWNED BY public.contact_types.id;


--
-- TOC entry 222 (class 1259 OID 49351)
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacts (
    id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    company_name character varying(200),
    phone character varying(20),
    type_id integer,
    owner_id integer
);


ALTER TABLE public.contacts OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 49350)
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO postgres;

--
-- TOC entry 4929 (class 0 OID 0)
-- Dependencies: 221
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- TOC entry 224 (class 1259 OID 49368)
-- Name: interactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interactions (
    id integer NOT NULL,
    contact_id integer,
    user_id integer,
    interaction_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text
);


ALTER TABLE public.interactions OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 49367)
-- Name: interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.interactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interactions_id_seq OWNER TO postgres;

--
-- TOC entry 4930 (class 0 OID 0)
-- Dependencies: 223
-- Name: interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.interactions_id_seq OWNED BY public.interactions.id;


--
-- TOC entry 226 (class 1259 OID 49388)
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    contact_id integer,
    title character varying(200) NOT NULL,
    due_date timestamp without time zone NOT NULL,
    status character varying(50) DEFAULT 'Новая'::character varying,
    CONSTRAINT tasks_status_check CHECK (((status)::text = ANY ((ARRAY['Новая'::character varying, 'В работе'::character varying, 'Завершена'::character varying])::text[])))
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 49387)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_id_seq OWNER TO postgres;

--
-- TOC entry 4931 (class 0 OID 0)
-- Dependencies: 225
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- TOC entry 218 (class 1259 OID 49330)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    is_admin boolean DEFAULT false
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 49329)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4932 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 227 (class 1259 OID 49404)
-- Name: vw_full_contacts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_full_contacts AS
 SELECT c.id,
    c.first_name,
    c.last_name,
    c.company_name,
    ct.type_name,
    u.username AS manager_name
   FROM ((public.contacts c
     JOIN public.contact_types ct ON ((c.type_id = ct.id)))
     JOIN public.users u ON ((c.owner_id = u.id)));


ALTER VIEW public.vw_full_contacts OWNER TO postgres;

--
-- TOC entry 4736 (class 2604 OID 49345)
-- Name: contact_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_types ALTER COLUMN id SET DEFAULT nextval('public.contact_types_id_seq'::regclass);


--
-- TOC entry 4737 (class 2604 OID 49354)
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- TOC entry 4738 (class 2604 OID 49371)
-- Name: interactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interactions ALTER COLUMN id SET DEFAULT nextval('public.interactions_id_seq'::regclass);


--
-- TOC entry 4740 (class 2604 OID 49391)
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- TOC entry 4734 (class 2604 OID 49333)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4916 (class 0 OID 49342)
-- Dependencies: 220
-- Data for Name: contact_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contact_types (id, type_name) FROM stdin;
1	Клиент
2	Поставщик
3	Партнер
\.


--
-- TOC entry 4918 (class 0 OID 49351)
-- Dependencies: 222
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contacts (id, first_name, last_name, company_name, phone, type_id, owner_id) FROM stdin;
1	Алексей	Смирнов	ООО "СтройОпт"	+7(999)123-45-67	1	1
2	Елена	Соколова	Завод "ЦементПлюс"	+7(495)765-43-21	2	1
3	Дмитрий	Волков	ТК "Деловые Линии"	+7(800)555-35-35	3	1
4	Мария	Иванова	ООО "Ремонт-Сервис"	+7(900)111-22-33	1	1
5	Иван	Петров	СпецТехника Аренда	+7(911)222-33-44	3	1
\.


--
-- TOC entry 4920 (class 0 OID 49368)
-- Dependencies: 224
-- Data for Name: interactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interactions (id, contact_id, user_id, interaction_date, notes) FROM stdin;
1	1	1	2026-06-05 01:46:55.951525	Первый звонок, отправил прайс-лист
2	1	1	2026-06-05 01:46:55.951525	Уточнил детали доставки арматуры
3	1	1	2026-06-05 01:46:55.951525	Согласовали скидку 5% на объем
4	1	1	2026-06-05 01:46:55.951525	Ждем оплату счета
5	2	1	2026-06-05 01:46:55.951525	Запросил новые цены на цемент М500
6	2	1	2026-06-05 01:46:55.951525	Попросил отсрочку платежа
7	3	1	2026-06-05 01:46:55.951525	Договорились о фуре на завтра
8	4	1	2026-06-05 01:46:55.951525	Клиент просит расчет сметы
9	5	1	2026-06-05 01:46:55.951525	Уточнил стоимость аренды крана
\.


--
-- TOC entry 4922 (class 0 OID 49388)
-- Dependencies: 226
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, contact_id, title, due_date, status) FROM stdin;
1	1	Проконтролировать оплату счета	2026-06-06 01:46:55.951525	Новая
2	1	Отгрузить арматуру со склада	2026-06-08 01:46:55.951525	Новая
3	1	Запросить отзыв о работе	2026-06-15 01:46:55.951525	Новая
4	2	Оплатить поставку цемента	2026-06-07 01:46:55.951525	В работе
5	2	Подписать доп. соглашение	2026-06-10 01:46:55.951525	Новая
6	3	Отправить логисту координаты склада	2026-06-05 03:46:55.951525	Новая
7	4	Выехать на объект для замеров	2026-06-06 01:46:55.951525	Новая
8	5	Согласовать время подачи крана	2026-06-05 05:46:55.951525	В работе
\.


--
-- TOC entry 4914 (class 0 OID 49330)
-- Dependencies: 218
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, hashed_password, is_admin) FROM stdin;
1	admin	admin@mail.ru	$pbkdf2-sha256$29000$dM65N8aY897b29tbq5Xyfg$RArd6V/DSSop5Oh2Qxpkbo1LhbrfGdTpDREB0.EtC9w	t
9	manager	manager@mail.ru	$pbkdf2-sha256$29000$ZkwphTAmxDhHKIVwLmWsNQ$OHrHTMgwq4o63NRm8zOlOa18E10.3kmxM5NiveN4TTM	f
\.


--
-- TOC entry 4933 (class 0 OID 0)
-- Dependencies: 219
-- Name: contact_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contact_types_id_seq', 12, true);


--
-- TOC entry 4934 (class 0 OID 0)
-- Dependencies: 221
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contacts_id_seq', 5, true);


--
-- TOC entry 4935 (class 0 OID 0)
-- Dependencies: 223
-- Name: interactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.interactions_id_seq', 9, true);


--
-- TOC entry 4936 (class 0 OID 0)
-- Dependencies: 225
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tasks_id_seq', 8, true);


--
-- TOC entry 4937 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 9, true);


--
-- TOC entry 4750 (class 2606 OID 49347)
-- Name: contact_types contact_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_types
    ADD CONSTRAINT contact_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4752 (class 2606 OID 49349)
-- Name: contact_types contact_types_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_types
    ADD CONSTRAINT contact_types_type_name_key UNIQUE (type_name);


--
-- TOC entry 4754 (class 2606 OID 49356)
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- TOC entry 4758 (class 2606 OID 49376)
-- Name: interactions interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_pkey PRIMARY KEY (id);


--
-- TOC entry 4761 (class 2606 OID 49395)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 4744 (class 2606 OID 49340)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4746 (class 2606 OID 49336)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4748 (class 2606 OID 49338)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4755 (class 1259 OID 49402)
-- Name: idx_contacts_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contacts_name ON public.contacts USING btree (last_name, first_name);


--
-- TOC entry 4756 (class 1259 OID 49401)
-- Name: idx_contacts_owner_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_contacts_owner_id ON public.contacts USING btree (owner_id);


--
-- TOC entry 4759 (class 1259 OID 49403)
-- Name: idx_tasks_contact_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_contact_id ON public.tasks USING btree (contact_id);


--
-- TOC entry 4762 (class 2606 OID 49362)
-- Name: contacts contacts_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4763 (class 2606 OID 49357)
-- Name: contacts contacts_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.contact_types(id) ON DELETE RESTRICT;


--
-- TOC entry 4764 (class 2606 OID 49377)
-- Name: interactions interactions_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- TOC entry 4765 (class 2606 OID 49382)
-- Name: interactions interactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interactions
    ADD CONSTRAINT interactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4766 (class 2606 OID 49396)
-- Name: tasks tasks_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


-- Completed on 2026-06-05 02:04:33

--
-- PostgreSQL database dump complete
--

\unrestrict kcDbqXNKuAazUSPrPQK3EGvI1FoSaLebonZhaRtLuCe5hr2zW4XmZuedZbyhjq3

