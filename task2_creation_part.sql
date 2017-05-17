-- DROP TABLE bom_lines;
-- DROP TABLE items ;
-- DROP TABLE bom_heads ;


-- without units of measure
CREATE TABLE bom_heads (name varchar(20) primary key);
CREATE TABLE items (name varchar(20) primary key, bom varchar(20) references bom_heads(name));
CREATE TABLE bom_lines (bom varchar(20) references bom_heads(name), line_no integer, type varchar(20), item varchar(20)  references items(name), qty integer);

INSERT INTO bom_heads (name) VALUES ('BOM1');
INSERT INTO bom_heads (name) VALUES ('BOM2');
INSERT INTO bom_heads (name) VALUES ('BOM3');
INSERT INTO bom_heads (name) VALUES ('BOM4');

INSERT INTO items (name, bom) VALUES ('A','BOM1');
INSERT INTO items (name, bom) VALUES ('B','BOM2');
INSERT INTO items (name, bom) VALUES ('C','BOM3');
INSERT INTO items (name, bom) VALUES ('D',NULL);
INSERT INTO items (name, bom) VALUES ('E',NULL);
INSERT INTO items (name, bom) VALUES ('F',NULL);
INSERT INTO items (name, bom) VALUES ('G','BOM4');

INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BOM1',1,'item','B',2);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BOM1',2,'item','C',2);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BOM2',1,'item','E',6);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BOM2',2,'item','F',5);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BOM3',1,'item','D',4);
INSERT INTO bom_lines (bom,line_no,type,item,qty) VALUES ('BOM4',1,'item','B',2);


-- DROP TABLE uos ;

-- with units of measure
CREATE TABLE uos (id integer primary key, name varchar, parent integer references uos(id), rate NUMERIC);

INSERT INTO uos (id,name,parent,rate) VALUES (1,'pcs',NULL,1);
INSERT INTO uos (id,name,parent,rate) VALUES (2,'box x10 pcs',1,10);
INSERT INTO uos (id,name,parent,rate) VALUES (3,'container x10 box',2,10);

CREATE TABLE bom_heads (name varchar(20) primary key);
CREATE TABLE items (name varchar(20) primary key, bom varchar(20) references bom_heads(name));
CREATE TABLE bom_lines (bom varchar(20) references bom_heads(name), line_no integer, type varchar(20), item varchar(20)  references items(name), qty integer, uos integer references uos(id));

INSERT INTO bom_heads (name) VALUES ('BOM1');

INSERT INTO items (name, bom) VALUES ('A','BOM1');
INSERT INTO items (name, bom) VALUES ('B',NULL);

INSERT INTO bom_lines (bom,line_no,type,item,qty,uos) VALUES ('BOM1',1,'item','B',2,3);

