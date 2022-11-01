--
-- PostgreSQL database dump
--

-- Dumped from database version 11.10
-- Dumped by pg_dump version 11.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

drop database eksgdbdemo ;
drop user dbuser1 ;

create database eksgdbdemo ;
\c eksgdbdemo;

create user dbuser1 password 'eksgdbdemo' ;
CREATE SCHEMA dbschema;
grant create on database eksgdbdemo to dbuser1;
grant all privileges on schema dbschema to dbuser1;
grant connect on database eksgdbdemo to dbuser1;
ALTER SCHEMA dbschema OWNER TO dbuser1;

--
-- Name: add_user(text, text, text, text); Type: PROCEDURE; Schema: dbschema; Owner: dbuser1
--

CREATE PROCEDURE dbschema.add_user(fname text, lname text, email text, password text)
    LANGUAGE plpgsql
    AS $$
begin
    insert into Users(fname, lname, email, password)
    values(fname, lname, email, password);
    commit;
end;$$;


ALTER PROCEDURE dbschema.add_user(fname text, lname text, email text, password text) OWNER TO dbuser1;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: apparels; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.apparels (
    id integer NOT NULL,
    name text,
    description text,
    img_url text,
    category text,
    inventory integer,
    price double precision
);


ALTER TABLE dbschema.apparels OWNER TO dbuser1;

--
-- Name: bicycles; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.bicycles (
    id integer NOT NULL,
    name text,
    description text,
    img_url text,
    category text,
    inventory integer,
    price double precision
);


ALTER TABLE dbschema.bicycles OWNER TO dbuser1;

--
-- Name: fashion; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.fashion (
    id integer NOT NULL,
    name text,
    description text,
    img_url text,
    category text,
    inventory integer,
    price double precision
);


ALTER TABLE dbschema.fashion OWNER TO dbuser1;

--
-- Name: jewelry; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.jewelry (
    id integer NOT NULL,
    name text,
    description text,
    img_url text,
    category text,
    inventory integer,
    price double precision
);


ALTER TABLE dbschema.jewelry OWNER TO dbuser1;

--
-- Name: kart; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.kart (
    userid integer NOT NULL,
    productid integer NOT NULL,
    qty integer
);


ALTER TABLE dbschema.kart OWNER TO dbuser1;

--
-- Name: order_details; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.order_details (
    order_id integer NOT NULL,
    item_id integer NOT NULL,
    qty integer,
    total numeric,
    unit_price numeric
);


ALTER TABLE dbschema.order_details OWNER TO dbuser1;

--
-- Name: orders; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.orders (
    order_id integer NOT NULL,
    customer_id integer,
    order_date date,
    order_total numeric,
    email text
);


ALTER TABLE dbschema.orders OWNER TO dbuser1;

--
-- Name: reviews; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.reviews (
    item_id integer NOT NULL,
    category text NOT NULL,
    username text NOT NULL,
    review text,
    rating integer
);


ALTER TABLE dbschema.reviews OWNER TO dbuser1;

--
-- Name: users; Type: TABLE; Schema: dbschema; Owner: dbuser1
--

CREATE TABLE dbschema.users (
    id integer NOT NULL,
    fname text,
    lname text,
    email text,
    password text
);


ALTER TABLE dbschema.users OWNER TO dbuser1;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: dbschema; Owner: dbuser1
--

CREATE SEQUENCE dbschema.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE dbschema.order_seq
    AS integer
    START WITH 4
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE dbschema.order_seq OWNER TO dbuser1;
ALTER SEQUENCE dbschema.users_id_seq OWNER TO dbuser1;
ALTER SEQUENCE dbschema.order_seq OWNER TO dbuser1;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: dbschema; Owner: dbuser1
--

ALTER SEQUENCE dbschema.users_id_seq OWNED BY dbschema.users.id;
ALTER SEQUENCE dbschema.order_seq OWNED BY dbschema.orders.order_id;


--
-- Name: users id; Type: DEFAULT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.users ALTER COLUMN id SET DEFAULT nextval('dbschema.users_id_seq'::regclass);


--
-- Data for Name: apparels; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.apparels (id, name, description, img_url, category, inventory, price) FROM stdin;
5000010	Guaranteed	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://unitedbyblue.com/ target=_blank>United By Blue</a>.</em></p>\n<ul>\n<li><span style=line-height: 1.4;>100% organic cotton, stone washed slub knit 6 oz jersey fabric</span></li>\n<li><span style=line-height: 1.4;>Made in California</span></li>\n</ul>\n<span style=line-height: 1.4;></span>\n<ul class=tabs-content></ul></p>	https://cdn.shopify.com/s/files/1/0803/6591/products/guaranteed_navy.jpeg?v=1426786281	Shirts	78	42.9500000000000028
5000000	The Scout Skincare Kit	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://unitedbyblue.com/ target=_blank>United By Blue</a>.</em></p><meta charset=utf-8>\n<p><span>A collection of the best Ursa Major has to offer! The Scout kit contains travel sizes of their best selling skin care items including: </span></p>\n<ul>\n<li><span style=line-height: 1.4;>Face Wash (2 fl oz)</span></li>\n<li><span style=line-height: 1.4;>Shave Cream (2 fl oz)</span></li>\n<li><span style=line-height: 1.4;>Face Balm (0.5 fl oz)</span></li>\n<li><span style=line-height: 1.4;>5 tonic-infused bamboo Face Wipes</span></li>\n</ul>\n<p><span>All wrapped together in a great, reusable tin.</span><span class=aam> </span></p></p>	https://cdn.shopify.com/s/files/1/0803/6591/products/skin-care_c18143d5-6378-46aa-b0d7-526aee3bc776.jpg?v=1426708827		0	13.9499999999999993
5000001	Ayres Chambray	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://unitedbyblue.com/ target=_blank>United By Blue</a>.</em></p>\n<p>Comfortable and practical, our chambray button down is perfect for travel or days spent on the go. The Ayres Chambray has a rich, washed out indigo color suitable to throw on for any event. Made with sustainable soft chambray featuring two chest pockets with sturdy and scratch resistant corozo buttons.</p>\n<ul class=tabs-content>\n<li><span style=line-height: 1.4;>100% Organic Cotton Chambray, 4.9 oz Fabric.</span></li>\n<li><span style=line-height: 1.4;>Natural Corozo Buttons.</span></li>\n</ul></p>	https://cdn.shopify.com/s/files/1/0803/6591/products/chambray_5f232530-4331-492a-872c-81c225d6bafd.jpg?v=1426630717	Shirts	64	198.949999999999989
5000002	Lodge	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://unitedbyblue.com/ target=_blank>United By Blue</a>.</em></p>\n<p>The lodge, after a day of white slopes, is a place of revelry, blazing fires and high spirits.</p>\n<ul>\n<li><span style=line-height: 1.4;>100% organic cotton, stone washed slub knit 6 oz jersey fabric</span></li>\n</ul></p>	https://cdn.shopify.com/s/files/1/0803/6591/products/lodge_women_white2_df6cafb7-1756-4991-8f1c-e074ecf4a5f2.jpeg?v=1426786254	Shirts	41	68.9500000000000028
5000012	5 Panel Camp Cap	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://unitedbyblue.com/ target=_blank>United By Blue</a>.</em></p>\n<p><span style=line-height: 1.4;>A classic 5 panel hat with our United By Blue logo on the front and an adjustable strap to keep fit and secure. Made with recycled polyester and organic cotton mix.</span></p>\n<ul>\n<li><span style=line-height: 1.5;>Made in New Jersey</span></li>\n<li><span style=line-height: 1.5;>7oz Eco-Twill fabric: 35% organic cotton, 65% recycled PET (plastic water and soda bottles) </span></li>\n<li><span style=line-height: 1.5;>Embossed leather patch</span></li>\n</ul>\n<ul class=tabs></ul>\n<p> </p>\n<ul class=tabs-content></ul></p>	https://cdn.shopify.com/s/files/1/0803/6591/products/5-panel-hat_4ee20a27-8d5a-490e-a2fc-1f9c3beb7bf5.jpg?v=1426709889	Accessories	48	111.950000000000003
\.


--
-- Data for Name: bicycles; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.bicycles (id, name, description, img_url, category, inventory, price) FROM stdin;
7000081	Micro Juliet	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=https://www.purefixcycles.com target=_blank>Pure Fix Cycles</a></em></p><p class=lead>Our Juliet is more midnight than morning sun.  Built to break hearts, this black-on-black bike can handle anything.</p></p>	https://cdn.shopify.com/s/files/1/0923/8062/products/JULIET_2014_SEAMLESS_SIDE_WEB.jpeg?v=1442434400	Black, Kids Fixie, Micro, Micro Series	7	162.949999999999989
7000183	Alfa	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=https://www.purefixcycles.com target=_blank>Pure Fix Cycles</a></em></p><p>Sunshine, blue skies, a gentle breeze – you can spend all year waiting for perfect bike weather or you can grab an Alfa and make your own. Whatever the forecast, Alfa makes every day a beautiful day for a ride.</p></p>	https://cdn.shopify.com/s/files/1/0923/8062/products/ALFA_SIDE_WEB.jpeg?v=1442512858	Bicycle, Bicycles, Bike, Blue, Fixed Gear, Fixie, Pure Fix Cycles, White, WTB	32	199.949999999999989
7000180	Crane Bell	<p><p></p></p>	https://cdn.shopify.com/s/files/1/0923/8062/products/crane-copper-bell-WEB.jpeg?v=1438625053	Accessories, Bells, Goods	94	76.9500000000000028
7000181	Interlock Integrated Bike Lock	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=https://www.purefixcycles.com target=_blank>Pure Fix Cycles</a></em></p><p>Annoyed by carrying your bike lock? The rattling, clanging, or ugly mounting hardware? The InterLock is a lock that hides inside of your bike! All you need to do is replace the seatpost with this one - that comes with a permanently attached bike lock!</p>\n<ul>\n<li>25.4mm seatpost</li>\n<li>﻿Cables are 90cm total length, or 35.4 inches if you’re imperially inclined.</li>\n<li>Product weight: 620 Grams including lock and seatpost.</li>\n<li>Seatpost is 3D Forged, 6061 Aluminium.</li>\n</ul></p>	https://cdn.shopify.com/s/files/1/0923/8062/products/Interlock_Black_3RD_WEB.jpeg?v=1438625046	Accessories, Locks, Saddles and Seatposts, Seatposts and Clamps	74	17.9499999999999993
\.


--
-- Data for Name: fashion; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.fashion (id, name, description, img_url, category, inventory, price) FROM stdin;
2	Bracelet 41 in Silver	<p><meta charset=utf-8>\n<p><span>Rustic links adorn a unisex bracelet. 1-100 jewelry gives an organic feel while maintaining an understated elegance. Varying chain-links. Hook-and-eye closure. Color Silver. 100% Sterling Silver. Made in U.S.A. </span><span><em>From Hook to Eye </em><em>Length </em></span><em>7 &amp; 1/2, Size Large. </em><em><em>Hook to Eye </em></em><em>Length 6, Size Small. </em></p>\n<p><a href=http://babyandco.us/collections/1-100><em>Shop our collection of 1-100. </em></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/product_bracelet_1-100_bracelet41_01.jpeg?v=1437081366	1-100, Accessories, arrivals, AW15, Bracelets, gift guide, jewelry, Man, mothermoon, signature, silver, spring2, visible, Woman	74	42.9500000000000028
3	Bracelet 3 in Silver	<p><meta charset=utf-8>\n<p><span>Rustic and lovely, 1-100 jewelry gives an organic feel while maintaining an understated elegance. Pummeled then polished, the 3 bracelet is a masterful addition. Color Silver. 100% Sterling Silver. Made in U.S.A. </span><em>Length 7, 1 &amp; 1/2 Wide. </em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/product_bracelet_1-100_bracelet3_01.jpeg?v=1441401623	1-100, Accessories, Bracelets, cooloff, gift guide, jewelry, last, Man, S14, silver, visible, Woman	99	90.9500000000000028
5	Bracelet 84 in Silver	<p><meta charset=utf-8>\n<p><span>Curved and lovely, 1-100 jewelry gives an organic touch to understated elegance. This cuff is intentionally designed to be lacking mechanical precision assures individuality to the wearer. Color Silver. 100% Sterling Silver. Made in U.S.A. <em>Length </em></span><span><em><em>6 &amp; 1/2, </em></em></span><em>2 &amp; 1/2 Wide. </em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-04-20_Accessories_20_12072_21332.jpeg?v=1437081343	1-100, Accessories, Bracelets, cooloff, Cuff, gift guide, last, putty, S14, Silver, visible, Woman	51	154.949999999999989
6	Ring 56 in Silver	<p><meta charset=utf-8>\n<p><span>Rustic yet lovely, 1-100 jewelry gives an organic feel while maintaining an understated elegance. Beautifully layered ring is smooth to touch, yet varying in texture. Color Silver. 100% Sterling Silver. Made in U.S.A. <em>Size Small 6, Size Large 11. </em></span></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-04-20_Accessories_23_12075_21344.jpeg?v=1437081338	1-100, Accessories, Man, Rings, S14, visible, Woman	2	199.949999999999989
41	Azur Bracelet in Blue Azurite	<p><meta charset=utf-8>\n<p> Elasticated, beaded bracelet by 5 Octobre. Gold details.</p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-05-08_Laydown_Look2_14120_21584.jpeg?v=1437080798	Accessories, bounty, Bracelets, copy, jewelry, S14, SALE, shot 5/8, Woman	65	173.949999999999989
40	Bi-Goutte Earrings	<p><meta charset=utf-8>\n<p>Quintessential elegance with delicate details. With the ease of the fish hook earring, the Bi-Goutte offers a handsome everyday piece. 5 Octobre. Color Green. Made in France. </p>\n<p><a href=http://babyandco.us/collections/5-octobre><em>Shop our collection of 5 Octobre. </em></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-05-01_Accessories_05_14103_21517.jpeg?v=1437080810	accessories, arrivals, AW15, bounty, earrings, jewelry, mothermoon, signature, sping6, spring6, woman	17	11.9499999999999993
30	Peone Jacket in Khaki	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p><span>Duvetica's reversible goose down gives you two jackets in one. The Peone Khaki upholds Duvetica's rigorous standards of down, warmth, and functionality. Exterior pockets with zips, full front zip placket connected to hood, elastic drawstring at hem. </span>Color Khaki. 100% Polyester, 100% Polyamide, 90% Grey Goose Down, 10% Feather. Made in Bulgaria. <em>Addis is wearing a 50.</em></p>\n<p><a href=http://babyandco.us/collections/duvetica-man><span style=text-decoration: underline;><em>Shop our collection of Duvetica.</em></span></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/1-26-15_Addis_Look_27_12858_1293.jpeg?v=1437081024	Duvetica, Man, Men's, Outerwear, S14, SALE, SALE30, visible	27	110.950000000000003
31	Curios Sweatshirt in Steel Grey	<p><meta charset=utf-8>\n<p><em>Addis is wearing a Small.</em></p>\n<meta charset=utf-8>\n<p><em><a href=http://babyandco.us/collections/hannes-roether-man><span><em>Shop our collection of Hannes Roether.</em></span></a></em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/1-26-15_Addis_Look_21_12990_1154_copy.jpeg?v=1437080999	Hannes Roether, Knitwear, Man, S14, tops, visible	99	109.950000000000003
32	Garbo Henley in Grey	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p><span>This knit henley offers comfort, yet longevity for the long-haul. With a touch of Cashmere, is it any wonder this piece is intensely touchable? Hannes Roether. </span>Color Grey. 90% Cotton, 10% Cashmere. Made in EU. <em>Addis is wearing a size Medium. </em><em><span class=s1>Addis is 6’2”, Chest 38.5”, Waist 31”, Inseam 32”.</span></em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_3_Addis_Look2_01.jpeg?v=1437080992	cyber, grey, Hannes Roether, heather, henley, Knitwear, last, long sleeve, Man, S14, SALE, SALE50, tee, tops, visible	74	122.950000000000003
33	Secon Shale Shirt in Slate	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>Understated yet classic, Hannes Roether’s pieces offer versatility through timeless silhouette. Basic long shirt with angled side seam. Color Slate. 100% Cotton. <em>Addis is wearing a Medium. Addis is 6’2”, Chest 38.5”, Waist 31”, Inseam 32”.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_3_Addis_Look10_02.jpeg?v=1437080985	charcoal, cotton, grey, Hannes Roether, Knitwear, long sleeve, Man, S14, SALE, shirt, slate, tops, visible	58	133.949999999999989
34	Stiro Oxford in Slate	<p><meta charset=utf-8>\n<p><span>Marsèll's Oxfords are a superb example of fine construction and simple design. The lace up design is reinvented with a pebbled effect finish. These versatile Italian made shoes will ensure long lasting comfort and cool through the seasons. Color Slate. 100% Leather. Made in Italy. </span></p>\n<p><em>Also Available in Chocolate, <a href=http://babyandco.us/products/stiro-oxford-petroleum-blue>Petroleum Blue</a>, and <a href=http://babyandco.us/products/stiro-oxford-black>Black</a>.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-05-13_Reshoot_Look4_13129_21790.jpeg?v=1437080975	accessories, cyber, footwear, grey, laydown reshoot, Leather, Man, Marsell, oxford, S14, SALE, SALE50, Shoes, slate, visible	51	156.949999999999989
35	Stiro Oxford in Black	<p><meta charset=utf-8>\n<p><span>Marsèll's Oxfords are a superb example of fine construction and simple design. The lace up design is reinvented with a pebbled effect finish. These versatile Italian made shoes will ensure long lasting comfort and cool through the seasons. Color Black. 100% Leather. Made in Italy. </span></p>\n<p><em>Also Available in Chocolate, <a href=http://babyandco.us/products/stiro-oxford-slate>Slate</a>, and <a href=http://babyandco.us/products/stiro-oxford-petroleum-blue>Petroleum Blue</a>.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-05-13_Reshoot_Look8_16572_21799.jpeg?v=1437080969	accessories, black, cyber, footwear, last, Leather, Man, Marsell, oxford, Relaxed Luxury, S14, SALE, SALE50, Shoes, visible	33	80.9500000000000028
36	Ink Splatter Shoulder Bag in Mustard/Blue	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p><em>Rebirth.</em> Foundational to Saisei’s philosophy comes the concept of reuse. Truly one-of-a-kind bags, Saisei embraces the forgotten and undesirable in order to create new. Leather handbag with a bright blue surprise. Exterior zip pocket, and top zip closure. Leather. Color Mustard/Blue.</p>\n<p><em>Also available in <a href=http://babyandco.us/products/ink-splatter-shoulder-bag-green-red>Green/Red</a>.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/product_bag_saisei_ink-splatter-shoulder-bag_mustardblue01.jpeg?v=1437080927	accessories, Bags, cyber, leather, measurement, purse, S14, Saisei, SALE, SALE50, suede, visible, Woman	19	49.9500000000000028
37	Brandy Tank in Black	<p><meta charset=utf-8>\n<p class=p1><span class=s1>Drifter's fluid tops are our foundation pieces and as basics they are anything but. This natural fit top offers an open back slit for subtle sexy. Color Black. 100% Micro Modal. Made in U.S.A. </span><em>Lana is wearing a size Medium.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_10_25_Lana_Look30_02.jpeg?v=1437080877	black, brandy tank, drifter, S14, t-shirts, top, tops, visible, Woman	87	27.9499999999999993
38	Backless Oxford in Black	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>A classic oxford is given a superbly slouchy redo. With the back half removed, the slide from Ter et Bantine is at once totally easy and a complete classic. Color Black. 100% Leather.</p>\n<p><em>Also available in <a href=http://babyandco.us/products/backless-oxford-brown>Brown</a>. </em></p>\n<p><a href=http://babyandco.us/collections/ter-et-bantine><em><span style=text-decoration: underline;>Shop our collection of Ter et Bantine.</span></em></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-04-30_Reshoot_03_13996_21431.jpeg?v=1437080839	arrivals, AW15, black, bounty, footwear, lace up, Minimal, Minimalism, new arrivals, oxford, Relaxed Luxury, reshoot, shoe, shoemoon, shoes, Signature, slip on, spring4, spring9, Ter et Bantine, visible, Woman	71	75.9500000000000028
39	Backless Oxford in Brown	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>A fresh take on the timeless menswear staple. Beautifully crafted leather shoe from Ter et Bantine slides perfectly into one’s daily ensemble. Color Brown. 100% Leather. Made in Italy.</p>\n<p><em>Also available in <a href=http://babyandco.us/products/s14-ter-se-3104e01-black>Black</a>. </em></p>\n<p><a href=http://babyandco.us/collections/ter-et-bantine><em><span style=text-decoration: underline;>Shop our collection of Ter et Bantine.</span></em></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-04-30_Reshoot_03_13988_21425.jpeg?v=1437080830	arrivals, AW15, backless, bounty, brown, footwear, Minimal, Minimalism, oxford, putty, reshoot, shoe, shoemoon, Shoes, Signature, Spring In Motion, spring5, Ter et Bantine, visible, Woman	2	89.9500000000000028
42	Leopold Bracelet in Green Chrysoprase	<p><p>Hues of jade offer a quiet elegance perfected for completion. Beautiful beads strung with gold accentuate silver statement pendant. 5 Octobre. Color Green Chrysoprase. </p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/product_bracelet_5octobre_leopold-bracelet_02.jpeg?v=1437080789	5 octobre, Accessories, bounty, Bracelets, gift guide, green, jewelry, S14, visible, Woman	3	148.949999999999989
43	Laurier Tee in Black/Navy	<p><p class=p1><span class=s1>Drifter's fluid tops are our foundation pieces and as basics they are anything but. This top's front panel is a dash of clever on the standard basic. Drifter. Color Black. 100% Micro Modal. <span>Made in U.S.A. </span></span><em>Lana is wearing a size Medium.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_10_25_Lana_Look19_01.jpeg?v=1437080714	arrivals, AW15, black, last, layered, navy, S14, signature, t-shirts, tops, visible, Woman	23	112.950000000000003
44	Goof Jacket in Tar	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>Understated yet classic, Hannes Roether’s pieces offer versatility through timeless silhouette. Woven jacket with unfinished hems. Standing collar. Hidden interior breast pocket. Fully lined. Color Tar. 100% Cotton. Made in Czech Republic. <em>Addis is wearing a size Medium. Addis is 6’2”, Chest 38.5”, Waist 31”, Inseam 32”</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_3_Addis_Look9_08.jpeg?v=1437080683	button, charcoal, cotton, cyber, grey, Hannes Roether, jacket, last, Man, Outerwear, S14, SALE, SALE50, tar, visible	12	130.949999999999989
45	Riga Jacket in Tar	<p><meta charset=utf-8><meta charset=utf-8>\n<p>Understated yet classic, Hannes Roether’s pieces offer versatility through timeless silhouette. Woven jacket with yoke detail. Accent lapels. Hidden interior breast pocket. Color Tar. 100% Linen. Made in Czech Republic. <em>Addis is wearing a size Small. Addis is 6’2”, Chest 38.5”, Waist 31”, Inseam 32”.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_3_Addis_Look8_02.jpeg?v=1437080664	blue, cyber, Hannes Roether, jacket, light, linen, Man, mens, Outerwear, S14, SALE, SALE50, suit, suits, tar, visible	30	40.9500000000000028
46	Daris Tee in Black	<p><meta charset=utf-8>\n<p><span>Understated yet classic, Roether’s pieces offer versatility through timeless silhouette. The Daris Tee presents raw refinery. Raglan sleeves and unfinished crew neckline. </span><span>Color Black. 100% Cotton. Made in EU. <em>Addis is wearing a Large,</em></span></p>\n<p><em>Also available in <a href=http://babyandco.us/products/daris-tee-blue>Blue</a> and <a href=http://babyandco.us/products/daris-tee-olive>Olive</a>.</em></p>\n<meta charset=utf-8>\n<p><span><em><em><a href=http://babyandco.us/collections/hannes-roether-man><span><em>Shop our collection of Hannes Roether.</em></span></a></em></em></span></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/1-26-15_Addis_Look_23_14594_1190.jpeg?v=1437080623	black, cotton, Hannes Roether, Man, S14, t-shirts, tops, visible	48	160.949999999999989
47	Daris Tee in Blue	<p><meta charset=utf-8>\n<p><span>Understated yet classic, Roether’s pieces offer versatility through timeless silhouette. The Daris Tee presents raw refinery. Raglan sleeves and unfinished crew neckline. </span>Color Blue. 100% Cotton. Made in EU. <em>Addis is wearing a Small.</em></p>\n<p><em>Also available in <a href=http://babyandco.us/products/daris-tee-olive>Olive</a> and <a href=http://babyandco.us/products/daris-tee-black>Black</a>.</em></p>\n<meta charset=utf-8>\n<p><em><em><a href=http://babyandco.us/collections/hannes-roether-man><span><em>Shop our collection of Hannes Roether.</em></span></a></em></em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/1-26-15_Addis_Look_22_14597_1175_copy.jpeg?v=1437080616	Hannes Roether, Man, S14, t-shirts, tops, visible	99	105.950000000000003
48	Daris Tee in Olive	<p><meta charset=utf-8>\n<p><span>Understated yet classic, Roether’s pieces offer versatility through timeless silhouette. The Daris Tee presents raw refinery. Raglan sleeves and unfinished crew neckline. </span><span>Color Olive. 100% Cotton. Made in EU. <em>Addis is wearing a Small.</em></span></p>\n<p><i>Also available in <a href=http://babyandco.us/products/daris-tee-blue>Blue</a> and <a href=http://babyandco.us/products/daris-tee-black>Black</a>.</i></p>\n<p><a href=http://babyandco.us/collections/hannes-roether-man><span style=text-decoration: underline;><em>Shop our collection of Hannes Roether.</em></span></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/1-26-15_Addis_Look_20_14602_1129.jpeg?v=1437080610	Hannes Roether, Man, S14, t-shirts, tops, visible	38	60.9500000000000028
49	Marquee Coat in Steel	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p><span>The Marquee Coat is the ideal sidekick. Intricately detailed hood and collar. Exterior chest and waist pockets. Elbow pads and detailed seaming. Waist and hip interior drawstring. Front button closure with full zip. Hannes Roether. Color Steel. 100% Cotton. Made in Czech Republic. <em>Lana is wearing the Medium.</em></span></p>\n<p> </p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_08_11_Lana_Look4_11.jpeg?v=1437080599	coat, Hannes Roether, hooded, jacket, marquee, navy, Outerwear, S14, salefav2, visible, Woman	6	126.950000000000003
50	Bizi Cap Toe Loafer in Rose/Aubergine	<p><meta charset=utf-8>\n<p><span data-sheets-value='[null,2,A slip-on loafer with a little extra pizazz. A beaded toe cap keeps you tapping as shimmery supple leather wraps the back. 3/4\\u201d heel and rubber sole to save you a trip to the cobbler. Leather interior. Colors Grey/Moss Gold and Rose/Aubergine.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,8]>A slip-on loafer with a little extra pizazz. A beaded toe cap keeps you tapping as shimmery supple leather wraps the back. Three quarter inch heel and rubber sole to save you a trip to the cobbler. Leather lining. Color Rose/Aubergine. <span>Made in Pakistan. </span></span></p>\n<p><em> <span data-sheets-value='[null,2,A slip-on loafer with a little extra pizazz. A beaded toe cap keeps you tapping as shimmery supple leather wraps the back. 3/4\\u201d heel and rubber sole to save you a trip to the cobbler. Leather interior. Colors Grey/Moss Gold and Rose/Aubergine.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,8]>Also available in <a href=http://babyandco.us/products/bizi-grey-moss-gold>Grey Moss/Gold</a>.</span> </em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/Product_Shoes_MeherKakalia_BiziCapToeLoafer_RoseAubergine01.jpeg?v=1437080576	accessories, aubergine, brown, cap toe, footwear, loafer, Meher Kakalia, metallic, plum, purple, S14, SALE, shoe, Shoes, taupe, visible, Woman	86	166.949999999999989
51	Unbalanced Cardigan in Black	<p><p class=p1>Maria Calderara never ceases to produce elegance. Lay beautifully over chambray button-ups or an evening gown, the Unbalanced Cardigan is wonderfully diverse. Varying sleeve size and length, oversized silhouette. Single front button closure. Color Black. 100% Polyester. Made in Italy. <em>Lana is wearing a Size 1. </em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_17_Lana_Look28_03.jpeg?v=1437080546	asymmetric, black, cardigan, cyber, Maria Calderara, S14, SALE, SALE50, silk, top, tops, visible, Woman	99	132.949999999999989
52	Hempel Shirt in White	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p><span>The Hempel Shirt is the all-purpose classic button down. Tailored to fit naturally and immaculately. Front button down placket, clean collar, standard cuff with button closure. Woven stripe </span>detail. Hannes Roether. Color White. 100% Cotton. Made in Romania. <em>Addis is wearing a size Medium. Addis is 6’2”, Chest 38.5”, Waist 31”, Inseam 32”. </em></p>\n<p><a href=http://babyandco.us/collections/hannes-roether-man><span style=text-decoration: underline;><em>Shop our collection of Hannes Roether.</em></span></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_3_Addis_Look7_01.jpeg?v=1437080521	button up, full moon, Hannes Roether, Man, pinstripe, S14, SALE, shirt, tops, visible, white	33	53.9500000000000028
53	Weave Jacket in Black/Blue	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>Distinctive and naturally confident, Manuela Arcari’s Hache label offers complete sophistication. Beautifully tailored with engaging texture, the Weave Jacket is an immediate addition for a multipurpose look. Color Black/Blue. 100% Polyester. <em>Lana is wearing a Size 38.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_17_Lana_Look14_06.jpeg?v=1437080504	black, blue, cyber, Hache, last, Minimalism, Outerwear, S14, SALE, SALE50, visible, Woman	13	66.9500000000000028
54	Tessuto Jacket in Navy	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>A sleek and sensible collarless coat from Ter et Bantine in a luxurious premium cotton twill that feels more like an easy denim. Raw edges at center front hide hand-sewn snaps. Center back vent and a small vent at each sleeve. Color Navy. 100% Cotton. <em>Lana is wearing the Size 42.</em></p>\n<p><em>Also available in <a href=http://babyandco.us/products/tessuto-jacket-cream>Cream</a>.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_08_11_Lana_Look1_07.jpeg?v=1437080492	Coat, cyber, Jacket, last, Minimalism, navy, Outerwear, S14, SALE, SALE50, Ter et Bantine, visible, Woman	41	114.950000000000003
55	Tessuto Jacket in Cream	<p><meta charset=utf-8><meta charset=utf-8>\n<p><span>A sleek and sensible collarless coat from Ter et Bantine in a luxurious premium cotton twill that feels more like an easy denim. Raw edges at center front hide hand-sewn snaps. Center back vent and a small vent at each sleeve. Color Cream. 100% Cotton. </span><em>Lana is wearing the Size 42.</em></p>\n<p><i>Also available in <a href=http://babyandco.us/products/tessuto-jacket-navy>Navy</a>.</i></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_08_11_Lana_Look5_03.jpeg?v=1437080479	cream, cyber, jacket, last, Minimalism, Outerwear, S14, SALE, SALE50, Ter et Bantine, visible, Woman	10	182.949999999999989
56	Tulle Pleat Skirt in Navy	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>Timeless and inventive, Manuela Arcari’s designs for Ter et Bantine are exquisitely minimalistic while including touches of femininity. A-line skirt with subtle paneling. Back darts add to clean silhouette. Zip closure in back. Color Navy. 63% Cotton, 21% Polyester, 16% Seta. Made in Italy.<em> Lana is wearing a Size 38.</em></p>\n<p><em>Also </em><em><em>available</em> in <a href=http://babyandco.us/products/tulle-pleat-skirt-cream>Cream</a>.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_17_Lana_Look13_03.jpeg?v=1437080466	a-line, below-the-knee, bottoms, cyber, navy, S14, SALE, SALE50, skirt, Ter et Bantine, tulle, visible, Woman	69	58.9500000000000028
57	Tulle Pleat Skirt in Cream	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>Timeless and inventive, Manuela Arcari’s designs for Ter et Bantine are exquisitely minimalistic while including touches of femininity. A-line skirt with subtle paneling. Back darts add to clean silhouette. <span>Zip closure in back. Color Cream. 63% Cotton, 21% Polyester, 16% Seta. Made in Italy. </span>Color Cream<em>. Lana is wearing a Size 38.</em></p>\n<p><em>Also </em><em><em>available</em> in <a href=http://babyandco.us/products/tulle-pleat-skirt-navy>Navy</a>. </em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_17_Lana_Look11_01.jpeg?v=1437080456	a-line, below-the-knee, bottoms, cream, cyber, S14, SALE, SALE50, Ter et Bantine, tulle, visible, Woman, women's	37	94.9500000000000028
58	Denim Dress in Denim	<p><p>A long and lean column of two-tone denim to satisfy any wardrobe's need for a zip up and go kind of dress.  So complete you won't need to accessorize unless you want to. Color Denim. 100% Cotton. <em>Lana is wearing an Italian 40.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_10_18_Lana_Look2601.jpeg?v=1437080444	cyber, Denim, Dress, dresses, S14, SALE, SALE50, salefav2, Sheath, Sleeveless, Ter et Bantine, visible, Woman	45	91.9500000000000028
59	Patterned Button Up in Beige	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p><em>Addis is wearing a 40</em></p>\n<p><a href=http://babyandco.us/collections/dnl><span style=text-decoration: underline;><em>Shop our collection of DNL.</em></span></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/1-26-15_Addis_Look_26_15581_1260.jpeg?v=1437080400	DNL, Man, S14, SALE, tops, visible	33	36.9500000000000028
60	Linen Button Up in Blue Diamond	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>DNL.<em> Addis is wearing a 40.</em></p>\n<p><a href=http://babyandco.us/collections/dnl><span style=text-decoration: underline;><em>Shop our collection of DNL.</em></span></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/1-26-15_Addis_Look_25_15595_1230.jpeg?v=1437080392	DNL, Man, S14, SALE, tops, visible	24	92.9500000000000028
61	Linen Western Shirt in Beige/Blue	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>Tailored woven shirts for men. Relaxed with western prints. DNL. Color Beige/Blue. 60% Linen, 40% Cotton. Made in Italy. <em>Addis is wearing a size 41. Addis is 6’2”, Chest 38.5”, Waist 31”, Inseam 32”.</em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_11_3_Addis_Look17_02.jpeg?v=1437080385	beige, blue, button up, cyber, DNL, Man, off white, pattern, S14, SALE, SALE50, shirt, stripes, tops, visible, western	1	65.9500000000000028
117	Fantasma Bag in Mud	<p><meta charset=utf-8>\n<p><span>A roomy and practical suede carryall is outfitted with two top handles and a shoulder strap for an adaptable carry. The Fantasma is linen lined, with two internal zip pockets, a zip closure, and a handy luggage tag. Marsell. Color Mud. 100% Leather, Lining 100% Linen. Made in Italy. </span></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-04-02_Accessories_26_21638_17902.jpeg?v=1437078572	accessories, Accessory, arrivals, AW15, Bags, F14, gift guide, handbag, Leather, Marsell, measurement, nightout, purse, Signature, spring3, visible, Woman	9	8.94999999999999929
62	Bracelet 65 in Black	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p>A singular oval roughly cast and attached with silver rings to a strap of black leather. All rings are closed and the piece is imaginatively left open to interpretation. Worn double wrapped as bracelet or around the neck, the 1-100 pieces are made by hand by designer/artist team Miguel Villalobos and Graham Tabor. Sterling Silver used throughout.</p>\n<p><a href=http://babyandco.us/collections/1-100><em>Shop our collection of 1-100. </em></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/product_bracelet_1-100_bracelet65_01_1024x1024_681b5c42-4d33-4aed-8583-514cc34173a9.jpeg?v=1437080344	1-100, Accessories, Accessory, AW15, black, Bracelets, F14, jewelry, last, leather, Man, measurement, mothermoon, one, one6/11, signature, visible, Woman	13	9.94999999999999929
63	Silver I.D. Bracelet in Sterling	<p><p class=p1><span class=s1>Rustic yet lovely, 1-100 jewelry gives an organic feel while maintaining an understated elegance. Varying chain-links with rugged I.D. bracelet slab. Hook-and-eye closure. 100% Sterling Silver. </span><em>Hook to Eye Length 7. </em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/product_bracelet_1-100_silver-id-bracelet_01_1024x1024_967ee005-f395-48cc-bc59-8c542bbc1774.jpeg?v=1437080341	1-100, Accessories, Bracelets, F14, jewelry, Man, spring2, sterling, visible, Woman	86	23.9499999999999993
64	Silver Coil Ring in Sterling	<p><p class=p1><span class=s1>Rustic yet lovely, 1-100 jewelry gives an organic feel while maintaining an understated elegance. Asymmetrical layered coils, branch-like and sophisticated. 100% Sterling Silver. </span><em><span class=s1>Size 6, Small. </span></em><span class=s1>Size 9, Medium.</span><span class=s1> </span><em><span class=s1> </span></em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-04-20_Accessories_21_15669_21336.jpeg?v=1437080337	1-100, Accessories, F14, Man, Rings, visible, Woman	43	66.9500000000000028
65	Western Arkansas Button-Up in Dark Hash Floral	<p><meta charset=utf-8>\n<style type=text/css><!--\n&lt;!--\n&amp;amp;amp;lt;!--\n&amp;amp;amp;amp;lt;!--\n&amp;amp;amp;amp;amp;lt;!--\ntd {border: 1px solid #ccc;}br {mso-data-placement:same-cell;}\n--&amp;amp;amp;amp;amp;gt;\n--&amp;amp;amp;amp;gt;\n--&amp;amp;amp;gt;\n--&gt;\n--></style>\n<p><span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back 100% Cotton, Available in Dark Hash Floral and Blue Floral.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]>A Western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back. Aglini. Color Dark Hash Floral. 100% Cotton. Made in Italy. </span></p>\n<p><span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back 100% Cotton, Available in Dark Hash Floral and Blue Floral.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]></span> <em> <span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back 100% Cotton, Available in Dark Hash Floral and Blue Floral.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]>Also available in <a href=http://babyandco.us/products/western-arkansas-button-up-blue-floral>Blue Floral</a> and <a href=http://babyandco.us/products/western-arkansas-button-up-grey-floral>Grey Floral.</a></span></em></p>\n<meta charset=utf-8>\n<p><em><span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back 100% Cotton, Available in Dark Hash Floral and Blue Floral.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]><a href=http://babyandco.us/collections/aglini><em><span>Shop our collection of Aglini.</span></em></a></span></em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014-08-25_Matt_Look_213.jpeg?v=1437080323	Aglini, Button-ups, Buttons, Cotton, F14, Floral, Man, Men's, SALE, SALE30, Shirt, top, tops, visible, Western	25	190.949999999999989
66	Western Arkansas Button-Up in Blue Floral	<p><meta charset=utf-8>\n<p><span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back 100% Cotton, Available in Dark Hash Floral and Blue Floral.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]>A Western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back. Aglini. Color Blue Floral. 100% Cotton. Made in Italy. </span><em style=line-height: 1.2;><span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back 100% Cotton, Available in Dark Hash Floral and Blue Floral.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]>Matt is wearing an Italian 42. Matt is 6’2”, Chest 38”, Waist 31”, Inseam 34.5”.</span></em></p>\n<p><em> <span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back 100% Cotton, Available in Dark Hash Floral and Blue Floral.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]>Also available in <a href=http://babyandco.us/products/western-arkansas-button-up-dark-hash-floral>Dark Hash Floral</a> and <a href=http://babyandco.us/products/western-arkansas-button-up-grey-floral>Grey Floral</a>.</span> </em></p>\n<meta charset=utf-8>\n<p><em><span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A western style shirt gets a sweet touch with an all over floral motif. Two flap pockets at the chest and a classic western style yoke finishes the back 100% Cotton, Available in Dark Hash Floral and Blue Floral.]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]><a href=http://babyandco.us/collections/aglini><em><span>Shop our collection of Aglini.</span></em></a></span></em></p>\n<meta charset=utf-8></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014-08-25_Matt_Look_164.jpeg?v=1437080316	Aglini, button up, Button-ups, Cotton, F14, floral, Man, Men's, Outer Warmth, print, SALE, SALE30, shirt, top, tops, visible, western	4	73.9500000000000028
67	Riccardo Button-Up in Plaid Multi	<p><meta charset=utf-8>\n<p><span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A multicolored plaid button up is crafted from a blend of soft wool and cotton and features distinctive gold metal buttons. A back yoke completes the shirt. 55% Wool, 45% Cotton]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]>A multicolored plaid button up is crafted from a blend of soft wool and cotton and features distinctive gold metal buttons. A back yoke completes the shirt. Aglini. Color Plaid Multi. 55% Wool, 45% Cotton. Made in Italy. </span><em style=line-height: 1.2;><span data-sheets-value='[null,2,Created from the vast experience of its 41 founding members this shirt delivers beautiful Italian tailoring and high quality fabrics and trims. A multicolored plaid button up is crafted from a blend of soft wool and cotton and features distinctive gold metal buttons. A back yoke completes the shirt. 55% Wool, 45% Cotton]' data-sheets-userformat=[null,null,8961,[null,0],null,null,null,null,null,null,null,1,0,null,null,null,11]>Matt is wearing a size 42. Matt is 6’2”, Chest 38”, Waist 31”, Inseam 34.5”.</span></em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014-08-25_Matt_Look_156.jpeg?v=1437080308	Aglini, Button-ups, Buttons, cotton, F14, Man, Plaid, SALE, SALE30_4, shirt, top, tops, visible, wool	72	54.9500000000000028
68	Stretch Tee in Milk	<p><meta charset=utf-8>\n<style type=text/css><!--\n&amp;lt;!--\n&amp;amp;lt;!--\n&amp;amp;amp;lt;!--\n&amp;amp;amp;amp;lt;!--\n&amp;amp;amp;amp;amp;lt;!--\n\ntd {border: 1px solid #ccc;}br {mso-data-placement:same-cell;}\n\n--&amp;amp;amp;amp;amp;gt;\n--&amp;amp;amp;amp;gt;\n--&amp;amp;amp;gt;\n--&amp;amp;gt;\n--&amp;gt;\n--></style>\n<p><span data-sheets-value='[null,2,With a soft hand that denotes it\\u2019s made in Italy origins this simple T-shirt has a surged hem at neck and waist. Color Black and Milk. 94% Cotton, 6% Elastane.]' data-sheets-userformat=[null,null,9153,[null,0],null,null,null,null,null,0,2,1,0,null,null,null,10]>With a soft hand that denotes its made in Italy origins this simple T-shirt has a surged hem at neck and waist. Album di Famiglia. Color Milk. 94% Cotton, 6% Elastane. Made in Italy. </span></p>\n<p><em> <span data-sheets-value='[null,2,With a soft hand that denotes it\\u2019s made in Italy origins this simple T-shirt has a surged hem at neck and waist. Color Black and Milk. 94% Cotton, 6% Elastane.]' data-sheets-userformat=[null,null,9153,[null,0],null,null,null,null,null,0,2,1,0,null,null,null,10]>Also available in <a href=http://babyandco.us/products/stretch-tee-black>Black</a>.</span> </em></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2014_08_10_Lana_Look05_267.jpeg?v=1437080271	Album di Famiglia, F14, SALE, SALE30_4, shirt, t-shirt, t-shirts, tee, tee shirt, tops, visible, Woman	52	199.949999999999989
973	Pearl Tee	<p>Inside-out always makes a statement. The Pearl Tee from Harvey Faircloth demonstrates the beauty of pearl knitting for the classic t-shirt. Scooped neckline. Color Navy. 100% Cotton. Made in U.S.A. <em>Ashley is wearing a US 2.</em></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-07-02_Ashley_16_50269_23854.jpeg?v=1437064362	arrivals, AW15, blue, Harvey Faircloth, Knit, navy, Shot 7/2/15, tops, Woman	50	56.9500000000000028
853	Freshwater Pearl Bracelet	<p><span>Kalosoma Jewelry demonstrates the rigorous beauty in the handmade. Five freshwater pearls nested delectable braided band. Scarab detail. Knotted closure. Color Brown. 100% Leather. Made in Mexico. <em>Length 7 1/2 inches. </em></span></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-04-20_Accessories_19_10036_21327.jpeg?v=1437065827	03/19, 6/1one, accessories, arrivals, AW15, bounty, bracelets, brown, cooloff, jewelry, Kalosoma, last, leather, mothermoon, one, one6/11, pearls, Shot 5/1, signature, woman	0	159.949999999999989
416	Ring 83 in Gold	<p><p><em>This is a demonstration store. You can purchase products like this from <a href=http://babyandco.us/ target=_blank>Baby &amp; Company</a></em></p><p><span>Rustic yet lovely, 1-100 jewelry gives an organic feel while maintaining an understated elegance. Double the ring, double the fun. </span>Color Gold. </p>\n<p><em>﻿Also available in <a href=http://babyandco.us/collections/accessories-woman/products/ring-83-in-sterling-silver>Sterling Silver</a>.</em></p>\n<meta charset=utf-8>\n<p><a href=http://babyandco.us/collections/1-100><span style=text-decoration: underline;><em>﻿Shop our collection of 1-100.</em></span></a></p></p>	https://cdn.shopify.com/s/files/1/0923/8036/products/2015-02-02_Accessories_08_21256_Gold_2063.jpeg?v=1437071260	1-100, 12/29, accessories, arrivals, AW15, jewelry, mothermoon, ring, signature, Spring In Motion, unisex, visible, WEEK01, woman	93	46.9500000000000028
\.


--
-- Data for Name: jewelry; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.jewelry (id, name, description, img_url, category, inventory, price) FROM stdin;
9000000	14k Wire Bloom Earrings	<p><div class=product-description rte itemprop=description>Sed in metus nec dui consequat vestibulum. In varius pretium nunc, sed bibendum mauris lacinia non. Praesent vel neque ut ligula porttitor vestibulum ac eu erat. Pellentesque quis turpis odio. Etiam auctor laoreet ligula, vel aliquam urna ornare sed. Praesent laoreet diam vitae lectus molestie pulvinar.</div>\n<div class=product-description rte itemprop=description>\n<ul>\n<li><span>Nullam blandit</span></li>\n<li><span>Vestibulum euismod</span></li>\n<li><span>Nullam venenatis </span></li>\n<li><span>Aenean a magna eros</span></li>\n</ul>\n</div></p>	https://cdn.shopify.com/s/files/1/0597/2185/products/18k-rose-gold-wire-bloom-earrings_afcace12-edfb-4c82-aba0-11462409947f.jpg?v=1406749652	Rose Gold	0	157.949999999999989
9000001	14k Solid Bloom Earrings	<p><div class=product-description rte itemprop=description>Sed in metus nec dui consequat vestibulum. In varius pretium nunc, sed bibendum mauris lacinia non. Praesent vel neque ut ligula porttitor vestibulum ac eu erat. Pellentesque quis turpis odio. Etiam auctor laoreet ligula, vel aliquam urna ornare sed. Praesent laoreet diam vitae lectus molestie pulvinar.</div>\n<div class=product-description rte itemprop=description>\n<ul>\n<li><span>Nullam blandit</span></li>\n<li><span>Vestibulum euismod</span></li>\n<li><span>Nullam venenatis </span></li>\n<li><span>Aenean a magna eros</span></li>\n</ul>\n</div></p>	https://cdn.shopify.com/s/files/1/0597/2185/products/18k-rose-gold-solid-bloom-earrings_35415c7b-3053-4247-a017-f60f03ade244.jpg?v=1406749643	Rose Gold	38	197.949999999999989
9000002	14k Intertwined Earrings	<p><div class=product-description rte itemprop=description>Sed in metus nec dui consequat vestibulum. In varius pretium nunc, sed bibendum mauris lacinia non. Praesent vel neque ut ligula porttitor vestibulum ac eu erat. Pellentesque quis turpis odio. Etiam auctor laoreet ligula, vel aliquam urna ornare sed. Praesent laoreet diam vitae lectus molestie pulvinar.</div>\n<div class=product-description rte itemprop=description>\n<ul>\n<li><span>Nullam blandit</span></li>\n<li><span>Vestibulum euismod</span></li>\n<li><span>Nullam venenatis </span></li>\n<li><span>Aenean a magna eros</span></li>\n</ul>\n</div></p>	https://cdn.shopify.com/s/files/1/0597/2185/products/18k-rose-gold-intertwined-earrings_2bcb98e2-ac48-44c8-bf3a-1fddc37e936a.jpg?v=1406749634	Rose Gold	52	106.950000000000003
9000003	14k Interlinked Earrings	<p><div class=product-description rte itemprop=description>Sed in metus nec dui consequat vestibulum. In varius pretium nunc, sed bibendum mauris lacinia non. Praesent vel neque ut ligula porttitor vestibulum ac eu erat. Pellentesque quis turpis odio. Etiam auctor laoreet ligula, vel aliquam urna ornare sed. Praesent laoreet diam vitae lectus molestie pulvinar.</div>\n<div class=product-description rte itemprop=description>\n<ul>\n<li><span>Nullam blandit</span></li>\n<li><span>Vestibulum euismod</span></li>\n<li><span>Nullam venenatis </span></li>\n<li><span>Aenean a magna eros</span></li>\n</ul>\n</div></p>	https://cdn.shopify.com/s/files/1/0597/2185/products/18k-white-interlinked-earrings_f954bffe-d751-48bd-903f-18b5c74e16cd.jpg?v=1406749625	White Gold	30	81.9500000000000028
9000004	14k Dangling Pendant Earrings	<p><div class=product-description rte itemprop=description>Sed in metus nec dui consequat vestibulum. In varius pretium nunc, sed bibendum mauris lacinia non. Praesent vel neque ut ligula porttitor vestibulum ac eu erat. Pellentesque quis turpis odio. Etiam auctor laoreet ligula, vel aliquam urna ornare sed. Praesent laoreet diam vitae lectus molestie pulvinar.</div>\n<div class=product-description rte itemprop=description>\n<ul>\n<li><span>Nullam blandit</span></li>\n<li><span>Vestibulum euismod</span></li>\n<li><span>Nullam venenatis </span></li>\n<li><span>Aenean a magna eros</span></li>\n</ul>\n</div></p>	https://cdn.shopify.com/s/files/1/0597/2185/products/18k-white-gold-dangling-pendant-earrings_17e71027-81d8-4a49-a455-2e5c205963ee.jpg?v=1406749608	White Gold	56	57.9500000000000028
9000005	14k Dangling Pendant Earrings	<p><div class=product-description rte itemprop=description>Sed in metus nec dui consequat vestibulum. In varius pretium nunc, sed bibendum mauris lacinia non. Praesent vel neque ut ligula porttitor vestibulum ac eu erat. Pellentesque quis turpis odio. Etiam auctor laoreet ligula, vel aliquam urna ornare sed. Praesent laoreet diam vitae lectus molestie pulvinar.</div>\n<div class=product-description rte itemprop=description>\n<ul>\n<li><span style=line-height: 1.5;>Nullam blandit</span></li>\n<li><span style=line-height: 1.5;>Vestibulum euismod</span></li>\n<li><span style=line-height: 1.5;>Nullam venenatis </span></li>\n<li><span style=line-height: 1.5;>Aenean a magna eros</span></li>\n</ul>\n</div></p>	https://cdn.shopify.com/s/files/1/0597/2185/products/18k-rose-gold-infinite-link-earrings_d3d4fd54-7016-4f3c-b3be-66aeb5c24d5f.jpg?v=1406749599	Rose Gold	58	47.9500000000000028
\.


--
-- Data for Name: kart; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.kart (userid, productid, qty) FROM stdin;
4	6	\N
4	8	\N
\.


--
-- Data for Name: order_details; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.order_details (order_id, item_id, qty, total) FROM stdin;
1	8	1	67.95
1	9	1	38.95
1	7	1	91.95
2	6	1	199.95
3	6	1	199.95
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.orders (order_id, customer_id, order_date, order_total) FROM stdin;
1	4	2021-06-08	200
2	4	2021-06-08	300
3	4	2021-06-08	200
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.reviews (item_id, category, username, review, rating) FROM stdin;
8	fashion	test1	awesome product 1	4
8	fashion	test2	awesome product 2	3
8	fashion	test3	awesome product 3	4
8	fashion	test4	awesome product 4	3
8	fashion	test5	awesome product 5	4
8	fashion	test6	awesome product 6	3
8	fashion	test7	awesome product 7	4
8	fashion	test8	awesome product 8	3
8	fashion	test9	awesome product 9	4
8	fashion	test10	awesome product 10	4
8	fashion	test11	awesome product 11	4
8	fashion	test12	awesome product 12	3
8	fashion	test13	awesome product 13	5
8	fashion	test14	awesome product 14	5
8	fashion	test15	awesome product 15	5
8	fashion	test16	awesome product 16	4
8	fashion	test17	awesome product 17	5
8	fashion	test18	awesome product 18	3
8	fashion	test19	awesome product 19	5
8	fashion	test20	awesome product 20	4
8	fashion	test21	awesome product 21	3
9	fashion	test1	awesome product 1	4
9	fashion	test2	awesome product 2	2
9	fashion	test3	awesome product 3	3
9	fashion	test4	awesome product 4	5
9	fashion	test5	awesome product 5	2
9	fashion	test6	awesome product 6	5
9	fashion	test7	awesome product 7	3
9	fashion	test8	awesome product 8	2
9	fashion	test9	awesome product 9	5
9	fashion	test10	awesome product 10	3
9	fashion	test11	awesome product 11	4
9	fashion	test12	awesome product 12	2
9	fashion	test13	awesome product 13	5
9	fashion	test14	awesome product 14	5
9	fashion	test15	awesome product 15	4
9	fashion	test16	awesome product 16	2
9	fashion	test17	awesome product 17	3
9	fashion	test18	awesome product 18	4
9	fashion	test19	awesome product 19	4
9	fashion	test20	awesome product 20	5
9	fashion	test21	awesome product 21	2
9	fashion	test22	awesome product 22	5
9	fashion	test23	awesome product 23	5
9	fashion	test24	awesome product 24	5
9	fashion	test25	awesome product 25	4
9	fashion	test26	awesome product 26	3
9	fashion	test27	awesome product 27	4
9	fashion	test28	awesome product 28	5
9	fashion	test29	awesome product 29	2
9	fashion	test30	awesome product 30	5
9	fashion	test31	awesome product 31	2
9	fashion	test32	awesome product 32	5
9	fashion	test33	awesome product 33	2
9	fashion	test34	awesome product 34	4
9	fashion	test35	awesome product 35	5
9	fashion	test36	awesome product 36	3
9	fashion	test37	awesome product 37	3
9	fashion	test38	awesome product 38	2
9	fashion	test39	awesome product 39	3
7	fashion	test1	awesome product 1	2
7	fashion	test2	awesome product 2	3
7	fashion	test3	awesome product 3	2
7	fashion	test4	awesome product 4	2
7	fashion	test5	awesome product 5	3
7	fashion	test6	awesome product 6	2
7	fashion	test7	awesome product 7	4
7	fashion	test8	awesome product 8	3
7	fashion	test9	awesome product 9	3
7	fashion	test10	awesome product 10	3
7	fashion	test11	awesome product 11	2
7	fashion	test12	awesome product 12	3
7	fashion	test13	awesome product 13	3
7	fashion	test14	awesome product 14	2
7	fashion	test15	awesome product 15	2
7	fashion	test16	awesome product 16	2
7	fashion	test17	awesome product 17	5
7	fashion	test18	awesome product 18	4
7	fashion	test19	awesome product 19	5
7	fashion	test20	awesome product 20	4
7	fashion	test21	awesome product 21	5
7	fashion	test22	awesome product 22	4
7	fashion	test23	awesome product 23	5
7	fashion	test24	awesome product 24	4
7	fashion	test25	awesome product 25	5
7	fashion	test26	awesome product 26	3
7	fashion	test27	awesome product 27	3
7	fashion	test28	awesome product 28	2
7	fashion	test29	awesome product 29	4
7	fashion	test30	awesome product 30	3
7	fashion	test31	awesome product 31	4
7	fashion	test32	awesome product 32	5
7	fashion	test33	awesome product 33	5
7	fashion	test34	awesome product 34	4
7	fashion	test35	awesome product 35	2
7	fashion	test36	awesome product 36	3
7	fashion	test37	awesome product 37	4
7	fashion	test38	awesome product 38	5
7	fashion	test39	awesome product 39	5
7	fashion	test40	awesome product 40	2
7	fashion	test41	awesome product 41	2
7	fashion	test42	awesome product 42	5
7	fashion	test43	awesome product 43	4
7	fashion	test44	awesome product 44	4
7	fashion	test45	awesome product 45	2
7	fashion	test46	awesome product 46	5
7	fashion	test47	awesome product 47	5
7	fashion	test48	awesome product 48	5
6	fashion	test1	awesome product 1	3
6	fashion	test2	awesome product 2	4
6	fashion	test3	awesome product 3	4
6	fashion	test4	awesome product 4	3
6	fashion	test5	awesome product 5	3
6	fashion	test6	awesome product 6	3
6	fashion	test7	awesome product 7	5
6	fashion	test8	awesome product 8	2
6	fashion	test9	awesome product 9	4
6	fashion	test10	awesome product 10	3
6	fashion	test11	awesome product 11	2
6	fashion	test12	awesome product 12	3
6	fashion	test13	awesome product 13	5
6	fashion	test14	awesome product 14	5
6	fashion	test15	awesome product 15	3
6	fashion	test16	awesome product 16	4
6	fashion	test17	awesome product 17	3
6	fashion	test18	awesome product 18	3
6	fashion	test19	awesome product 19	2
6	fashion	test20	awesome product 20	2
6	fashion	test21	awesome product 21	2
6	fashion	test22	awesome product 22	5
6	fashion	test23	awesome product 23	2
6	fashion	test24	awesome product 24	3
6	fashion	test25	awesome product 25	5
6	fashion	test26	awesome product 26	5
6	fashion	test27	awesome product 27	2
6	fashion	test28	awesome product 28	5
6	fashion	test29	awesome product 29	4
6	fashion	test30	awesome product 30	5
6	fashion	test31	awesome product 31	4
6	fashion	test32	awesome product 32	2
6	fashion	test33	awesome product 33	4
6	fashion	test34	awesome product 34	2
6	fashion	test35	awesome product 35	3
6	fashion	test36	awesome product 36	5
6	fashion	test37	awesome product 37	3
6	fashion	test38	awesome product 38	3
6	fashion	test39	awesome product 39	5
6	fashion	test40	awesome product 40	2
6	fashion	test41	awesome product 41	4
6	fashion	test42	awesome product 42	2
6	fashion	test43	awesome product 43	4
6	fashion	test44	awesome product 44	3
6	fashion	test45	awesome product 45	2
6	fashion	test46	awesome product 46	5
6	fashion	test47	awesome product 47	2
6	fashion	test48	awesome product 48	3
6	fashion	test49	awesome product 49	2
6	fashion	test50	awesome product 50	2
6	fashion	test51	awesome product 51	4
6	fashion	test52	awesome product 52	3
6	fashion	test53	awesome product 53	2
6	fashion	test54	awesome product 54	5
6	fashion	test55	awesome product 55	5
6	fashion	test56	awesome product 56	5
6	fashion	test57	awesome product 57	4
6	fashion	test58	awesome product 58	5
6	fashion	test59	awesome product 59	4
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: dbschema; Owner: dbuser1
--

COPY dbschema.users (id, fname, lname, email, password) FROM stdin;
1	krishna	sarabu	okokkadu@yahoo.com	welcome
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: dbschema; Owner: dbuser1
--

SELECT pg_catalog.setval('dbschema.users_id_seq', 6, true);


--
-- Name: apparels apparels_pkey; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.apparels
    ADD CONSTRAINT apparels_pkey PRIMARY KEY (id);


--
-- Name: bicycles bicycles_pkey; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.bicycles
    ADD CONSTRAINT bicycles_pkey PRIMARY KEY (id);


--
-- Name: fashion fashion_pkey; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.fashion
    ADD CONSTRAINT fashion_pkey PRIMARY KEY (id);


--
-- Name: jewelry jewelry_pkey; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.jewelry
    ADD CONSTRAINT jewelry_pkey PRIMARY KEY (id);


--
-- Name: kart kart_pk; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.kart
    ADD CONSTRAINT kart_pk PRIMARY KEY (userid, productid);


--
-- Name: order_details order_details_pk; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.order_details
    ADD CONSTRAINT order_details_pk PRIMARY KEY (order_id, item_id);


--
-- Name: orders orders_pk; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.orders
    ADD CONSTRAINT orders_pk PRIMARY KEY (order_id);


--
-- Name: reviews reviews_pk; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.reviews
    ADD CONSTRAINT reviews_pk PRIMARY KEY (item_id, category, username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: dbschema; Owner: dbuser1
--

ALTER TABLE ONLY dbschema.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


alter user dbuser1 set search_path="dbschema", "public";
--
-- PostgreSQL database dump complete
--

