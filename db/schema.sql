create table if not exists events (
        id integer primary key autoincrement,
        date_value integer not null, -- months since 1 BCE
        date_precision integer not null, -- 0 (exact), 1 (after), 2 (before), 3 (circa, about)
        title varchar(255) not null,
        created_at timestamp not null,
        updated_at timestamp not null
);
create index if not exists events_date_and_precision on events(date, precision);
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
