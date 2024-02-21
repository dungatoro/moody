/*
Migrations are added to this file in sequence.
Always make use of `if not exists` to avoid overwrites.
*/
-- Create the users table
create table if not exists users (
    id            integer primary key,
    email         text not null unique,
    username      text not null, 
    password_hash text not null
);

-- Create the moods table
create table if not exists moods (
    id        integer primary key,
    user_id   integer not null, 
    mood      text not null,
    note      text not null,
    timestamp integer not null,
    foreign key(user_id) references users(id)
);
