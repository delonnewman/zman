create table if not exists layers (
       id integer primary key autoincrement,
       slug varying char not null,
       name varying char not null,
       description varying char not null,
       created_at timestamp not null,
       updated_at timestamp not null
);
create index if not exists layers_slug on layers(slug);
create index if not exists layers_timestamps on layers(created_at, updated_at);

create table if not exists events (
        id integer primary key autoincrement,
        start_on_value integer not null, -- months since 1 BCE
        start_on_precision integer not null, -- 0 (exact), 1 (after), 2 (before), 3 (circa, about)
        end_on_value integer not null, -- months since 1 BCE
        end_on_precision integer not null, -- 0 (exact), 1 (after), 2 (before), 3 (circa, about)
        layer_id integer not null references layers(id),
        title varying char not null,
        created_at timestamp not null,
        updated_at timestamp not null
);
create index if not exists events_start_on_and_precision on events(start_on_value, start_on_precision);
create index if not exists events_end_on_and_precision on events(end_on_value, end_on_precision);
create index if not exists events_layer_id on events(layer_id);
create index if not exists events_title on events(title);
create index if not exists events_timestamps on events(created_at, updated_at);

create table if not exists notes (
       id integer primary key autoincrement,
       event_id integer not null references events(id),
       content text not null,
       created_at timestamp not null,
       updated_at timestamp not null
);
create index if not exists notes_event_id on notes(event_id);
create index if not exists notes_timestamps on notes(created_at, updated_at);
