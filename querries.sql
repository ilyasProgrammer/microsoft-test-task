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

SELECT B.code,B.post_date, SUM(A.amount)
FROM A A, A B
WHERE A.post_date<=B.post_date
GROUP BY  B.code,B.post_date

SELECT post_date, amount,
    (SELECT SUM(amount)
     FROM A
     WHERE n.code = new_meetings.code
         AND A.post_date<=n.post_date) as total
FROM A n