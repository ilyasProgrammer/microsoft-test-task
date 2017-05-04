CREATE DATABASE ms OWNER ra;
CREATE TABLE A (
    id SERIAL CONSTRAINT firstkey PRIMARY KEY,
    code char(20),
    post_date date,
    amount  integer NOT NULL CHECK (amount > 0)
);
INSERT INTO A (code, post_date, amount) VALUES ('A-100', '2017-10-10', 101);
INSERT INTO A (code, post_date, amount) VALUES ('A-101', '2017-10-10', 102);
INSERT INTO A (code, post_date, amount) VALUES ('A-101', '2017-10-10', 105);
