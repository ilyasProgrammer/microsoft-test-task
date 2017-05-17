-- without units of measure
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


-- with units of measure
-- selection does not do recursive units calculations.
CREATE TEMPORARY TABLE root_parts ON COMMIT DROP AS (SELECT i.name PART, l.item SUBPART, l.qty*u.rate QUANTITY
			     FROM items i
			     LEFT JOIN bom_lines l ON i.bom = l.bom
			     LEFT JOIN uos u ON l.uos = u.id WHERE i.name = 'A') ;
CREATE TEMPORARY TABLE all_parts ON COMMIT DROP AS (SELECT i.name PART,l.item SUBPART,l.qty*u.rate QUANTITY
			    FROM items i
			    LEFT JOIN bom_lines l ON i.bom = l.bom
			    LEFT JOIN uos u ON l.uos = u.id);
CREATE TEMPORARY TABLE end_parts ON COMMIT DROP AS (SELECT i.name PART
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