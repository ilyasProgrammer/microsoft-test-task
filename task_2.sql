DROP TABLE bom_lines;
DROP TABLE items ;
DROP TABLE bom_heads ;

--TABLES CREATION
CREATE TABLE bom_heads (name varchar(20) primary key);
CREATE TABLE items (name varchar(20) primary key, bom varchar(20) references bom_heads(name));
CREATE TABLE bom_lines (bom varchar(20) references bom_heads(name), line_no integer, type varchar(20), item varchar(20)  references items(name), qty integer);

--DATA INSERT
INSERT INTO bom_heads (name) VALUES ('BM1');
INSERT INTO bom_heads (name) VALUES ('BM2');
INSERT INTO bom_heads (name) VALUES ('BM3');

INSERT INTO items (name, bom) VALUES ('A','BM1');
INSERT INTO items (name, bom) VALUES ('B','BM2');
INSERT INTO items (name, bom) VALUES ('C','BM3');
INSERT INTO items (name, bom) VALUES ('D',NULL);
INSERT INTO items (name, bom) VALUES ('E',NULL);
INSERT INTO items (name, bom) VALUES ('F',NULL);

INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BM1',1,'item','B',2);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BM1',2,'item','C',3);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BM2',1,'item','E',4);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BM2',2,'item','F',5);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BM3',1,'item','D',6);

--DATA SELECTION
CREATE TEMPORARY TABLE root_parts ON COMMIT DROP AS
                (SELECT i.name PART, l.item SUBPART, l.qty QUANTITY
			     FROM items i
			     LEFT JOIN bom_lines l ON i.bom = l.bom WHERE i.name = 'A') ;
CREATE TEMPORARY TABLE all_parts ON COMMIT DROP AS
                (SELECT i.name PART,l.item SUBPART,l.qty QUANTITY
			     FROM items i
			     LEFT JOIN bom_lines l ON i.bom = l.bom);
CREATE TEMPORARY TABLE end_parts ON COMMIT DROP AS
                (SELECT i.name PART
			     FROM items i
			     LEFT JOIN bom_lines l ON i.bom = l.bom WHERE l.item IS NULL);

WITH RECURSIVE REQ (PART, SUBPART, QUANTITY) AS
  ( SELECT * FROM root_parts
    UNION ALL
    SELECT PARENT.PART, CHILD.SUBPART, PARENT.QUANTITY*CHILD.QUANTITY
    FROM REQ PARENT, (SELECT * FROM all_parts) CHILD
    WHERE PARENT.SUBPART = CHILD.PART )

SELECT PART, SUBPART, SUM(QUANTITY) AS "Total QTY"
FROM REQ
WHERE SUBPART IN (SELECT * FROM end_parts)
GROUP BY PART, SUBPART
ORDER BY PART, SUBPART;