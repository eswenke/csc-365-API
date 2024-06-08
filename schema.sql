-- schemas
create table
public.narcos (
    id bigint generated by default as identity,
    name text null,
    price integer null,
    rarity integer null,
    constraint narcos_pkey primary key (id)
) tablespace pg_default;

create table
public.wars (
    id integer generated by default as identity,
    planet_1 text not null default ''::text,
    planet_2 text not null default ''::text,
    citizen_id integer null default 0,
    min_bid integer null default 0,
    constraint wars_pkey primary key (id)
) tablespace pg_default;

create table
public.planets (
    planet text not null,
    war_id integer not null,
    constraint planets_pkey primary key (planet),
    constraint planets_war_id_fkey foreign key (war_id) references wars (id)
) tablespace pg_default;
                                
create table
public.citizens (
    id integer generated by default as identity,
    name text not null default ''::text,
    role text not null default ''::text,
    strikes integer not null default 0,
    planet text not null,
    password text null,
    coolness integer not null default 0,
    constraint civilians_pkey primary key (id),
    constraint citizens_planet_fkey foreign key (planet) references planets (planet)
) tablespace pg_default;

create table
public.transactions (
    transaction_id integer generated by default as identity,
    buyer_id integer null,
    constraint transactions_pkey primary key (transaction_id),
    constraint transactions_buyer_id_fkey foreign key (buyer_id) references citizens (id)
) tablespace pg_default;      
                              
create table
public.transaction_items (
    transaction_id integer not null,
    listing_id integer not null default 0,
    constraint transaction_items_pkey primary key (transaction_id),
    constraint transaction_items_transaction_id_fkey foreign key (transaction_id) references transactions (transaction_id)
) tablespace pg_default;

create table
public.inventory (
    citizen_id integer not null,
    type text not null default ''::text,
    quantity integer null default 0,
    name text not null default ''::text,
    status text null,
    id integer generated by default as identity,
    constraint inventory_pkey primary key (id),
    constraint unique_entry unique (
    citizen_id,
    type,
    name,
    status
    ),
    constraint public_inventory_citizen_id_fkey foreign key (citizen_id) references citizens (id)
) tablespace pg_default; 
    
create table
public.market (
    id integer generated by default as identity,
    name text not null default ''::text,
    type text not null default ''::text,
    price integer not null default 0,
    quantity integer not null default 0,
    seller_id integer null,
    timestamp timestamp without time zone null default now(),
    constraint market_pkey primary key (id),
    constraint market_seller_id_fkey foreign key (seller_id) references citizens (id)
) tablespace pg_default;
                              
create table
public.substances (
    id integer generated by default as identity,
    name text null,
    price integer null,
    rarity integer null,
    planet text null,
    quantity integer null default 0,
    to_narco integer null default 10,
    constraint substances_pkey primary key (id),
    constraint substances_planet_fkey foreign key (planet) references planets (planet)
) tablespace pg_default;
                              
create table
public.bids (
    citizen_id integer not null default 0,
    war_id integer not null default 0,
    bid_amount integer null default 0,
    planet text null default ''::text,
    constraint bids_pkey primary key (citizen_id, war_id),
    constraint bids_citizen_id_fkey foreign key (citizen_id) references citizens (id),
    constraint bids_planet_fkey foreign key (planet) references planets (planet),
    constraint bids_war_id_fkey foreign key (war_id) references wars (id) on update cascade on delete cascade
) tablespace pg_default;

-- inserts to populate:
-- wars
-- insert into wars (planet_1, planet_2) values ('peace', 'peace');

-- planets
-- insert into planets (planet, war_id) values ('Lyxion IV', 1);
-- insert into planets (planet, war_id) values ('Zentharis', 1);
-- insert into planets (planet, war_id) values ('Sylvaria', 1);
-- insert into planets (planet, war_id) values ('Pyre', 1);
-- insert into planets (planet, war_id) values ('Ecliptix', 1);

-- citizens
-- insert into citizens (name, role, strikes, planet) values ('citizen 1', 'civilian', 0, 'Pyre');
-- insert into citizens (name, role, strikes, planet) values ('citizen 2', 'miner', 0, 'Lyxion IV');
-- insert into citizens (name, role, strikes, planet) values ('citizen 3', 'chemist', 0, 'Zentharis');
-- insert into citizens (name, role, strikes, planet) values ('citizen 4', 'govt', 0, 'Sylvaria');

-- narcos
-- insert into narcos (name, price, rarity) values ('SLT', 8, 1);
-- insert into narcos (name, price, rarity) values ('Goxin', 12, 2);
-- insert into narcos (name, price, rarity) values ('Splice', 20, 3);
-- insert into narcos (name, price, rarity) values ('Starbliss', 30, 4);
-- insert into narcos (name, price, rarity) values ('Vibe', 40, 5);
-- insert into narcos (name, price, rarity) values ('Cocaine', 75, 6);

-- substances
-- insert into substances (name, price, rarity, planet, quantity, to_narco) values ('Siltrite', 2, 1, 'Lyxion IV', 1000, 10);
-- insert into substances (name, price, rarity, planet, quantity, to_narco) values ('Garnox', 3, 2, 'Sylvaria', 1000, 10);
-- insert into substances (name, price, rarity, planet, quantity, to_narco) values ('Lumidium', 5, 3, 'Pyre', 1000, 10);
-- insert into substances (name, price, rarity, planet, quantity, to_narco) values ('Vibranium', 8, 4, 'Ecliptix', 1000, 10);
-- insert into substances (name, price, rarity, planet, quantity, to_narco) values ('Starstone', 15, 5, 'Zentharis', 1000, 10);

-- inventory (initialize inventory of every citizen with 100 voidex, give dummy narcos & substances)
-- INSERT INTO inventory (citizen_id, quantity, type)
-- SELECT id, 500, 'voidex'
-- FROM citizens;

-- example inserts for citizen inventory
-- insert into inventory (citizen_id, quantity, name, type, status) values (1, 10, 'SLT', 'narcos', 'owned');
-- insert into inventory (citizen_id, quantity, name, type, status) values (1, 6, 'Starbliss', 'narcos', 'owned');
-- insert into inventory (citizen_id, quantity, name, type, status) values (1, 2, 'Vibe', 'narcos', 'owned');
-- insert into inventory (citizen_id, quantity, name, type, status) values (1, 9, 'Goxin', 'narcos', 'owned');

-- insert into inventory (citizen_id, quantity, name, type, status) values (2, 3, 'Lumidium', 'substances', 'selling');
-- insert into inventory (citizen_id, quantity, name, type, status) values (2, 5, 'Vibranium', 'substances', 'selling');
-- insert into inventory (citizen_id, quantity, name, type, status) values (2, 1, 'Starstone', 'substances', 'selling');
-- insert into inventory (citizen_id, quantity, name, type, status) values (2, 9, 'Siltrite', 'substances', 'selling');

-- insert into inventory (citizen_id, quantity, name, type, status) values (3, 8, 'Splice', 'narcos', 'selling');
-- insert into inventory (citizen_id, quantity, name, type, status) values (3, 7, 'Starbliss', 'narcos', 'selling');
-- insert into inventory (citizen_id, quantity, name, type, status) values (3, 1, 'Vibe', 'narcos', 'selling');
-- insert into inventory (citizen_id, quantity, name, type, status) values (3, 3, 'Cocaine', 'narcos', 'selling');