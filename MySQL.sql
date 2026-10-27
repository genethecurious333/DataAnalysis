CREATE DATABASE myflaskdb DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;

CREATE DATABASE shopdb 
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
    
USE shopdb;
    
DROP DATABASE IF EXISTS myflaskdb;    

CREATE TABLE customers (
    customer_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    age INT CHECK (age >= 0 AND age <= 150),
    city VARCHAR(50) DEFAULT '미입력',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
    product_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    category VARCHAR(50),
    PRIMARY KEY (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE orders (
    order_id     INT           NOT NULL AUTO_INCREMENT,
    customer_id  INT           NOT NULL,
    product_id   INT           NOT NULL,
    quantity     INT           NOT NULL DEFAULT 1,
    order_date   DATETIME      DEFAULT CURRENT_TIMESTAMP,
    status       VARCHAR(20)   DEFAULT '주문완료',
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
DESC customers;
SHOW CREATE TABLE customers;
ALTER TABLE customers ADD COLUMN gender CHAR(1);
ALTER TABLE customers MODIFY COLUMN phone VARCHAR(30);
ALTER TABLE customers DROP COLUMN gender;
ALTER TABLE customers RENAME TO members;
DROP TABLE IF EXISTS orders;
INSERT INTO customers (name, email, phone, age, city)
    VALUES ('홍길동', 'hong@email.com', '010-1234-5678', 30, '서울');
INSERT INTO customers (name, email, phone, age, city)
VALUES
    ('김영희', 'kim@email.com', '010-2222-3333', 25, '부산'),
    ('이철수', 'lee@email.com', '010-3333-4444', 35, '대구'),
    ('박민준', 'park@email.com', '010-4444-5555', 28, '서울'),
    ('최수진', 'choi@email.com', '010-5555-6666', 42, '인천');
    
INSERT INTO products (name, price, stock, category)
VALUES
    ('노트북', 1200000, 50, '전자제품'),
    ('스마트폰', 800000, 100, '전자제품'),
    ('무선이어폰', 150000, 200, '전자제품'),
    ('청바지', 59000, 80, '의류'),
    ('운동화', 89000, 60, '신발');  
    
INSERT INTO orders (customer_id, product_id, quantity, status)
VALUES
    (1, 1, 1, '주문완료'),
    (1, 3, 2, '배송중'),
    (2, 2, 1, '주문완료'),
    (3, 4, 3, '배송완료'),
    (4, 5, 1, '주문완료');
    
SELECT * FROM customers;    
SELECT name, email, city FROM customers;
SELECT DISTINCT city FROM customers;
SELECT * FROM customers WHERE age >= 30;
SELECT name, city FROM customers WHERE city = '서울';
SELECT * FROM customers WHERE city = '서울' AND age >= 25;
SELECT * FROM customers WHERE city = '서울' OR city = '부산';
SELECT * FROM customers WHERE age BETWEEN 25 AND 35;
SELECT * FROM customers WHERE city IN ('서울', '부산', '대구');
SELECT * FROM customers WHERE name LIKE '김%';     -- '김'으로 시작
SELECT * FROM customers WHERE email LIKE '%@email.com';
SELECT * FROM customers WHERE phone IS NULL;
SELECT * FROM customers WHERE phone IS NOT NULL;

-- 정렬(ORDER BY)
SELECT * FROM customers ORDER BY age ASC;
SELECT * FROM customers ORDER BY age DESC, name ASC;

-- 제한(LIMIT)
SELECT * FROM customers ORDER BY age DESC LIMIT 3;
SELECT * FROM customers LIMIT 3 OFFSET 3;

SELECT COUNT(*) AS 총고객수 FROM customers;
SELECT AVG(age) AS 평균나이, 
    MAX(age) AS 최고나이, 
    MIN(age) AS 최저나이 
    FROM customers;

SELECT MAX(price) AS 최고가,
    MIN(price) AS 최저가,
    SUM(stock) AS 총재고
    FROM products;    

SELECT city, COUNT(*) AS 고객수
    FROM customers
    GROUP BY city;  

SELECT category,
    COUNT(*)       AS 상품수,
    AVG(price)     AS 평균가격,
    SUM(stock)     AS 총재고
    FROM products
    GROUP BY category
    HAVING AVG(price) >= 80000
    ORDER BY 평균가격 DESC;
select * from orders;    
SELECT c.name  AS 고객명,
    p.name    AS 상품명,
    o.quantity  AS 수량,
    o.status    AS 상태,
    o.order_date  AS 주문일
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    INNER JOIN products p ON o.product_id = p.product_id
    ORDER BY o.order_date DESC;  
    
SELECT c.name  AS 고객명,
    p.name    AS 상품명,
    o.quantity  AS 수량,
    o.status    AS 상태,
    o.order_date  AS 주문일
    FROM orders o, customers c, products p
    WHERE o.customer_id = c.customer_id AND
          o.product_id = p.product_id
    ORDER BY o.order_date DESC;
    
SELECT c.name   AS 고객명,
    o.order_id  AS 주문번호,
    o.status   AS 상태
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id;  
    
SELECT c.name  AS 고객명,
    COUNT(o.order_id) AS 주문건수,
    SUM(p.price * o.quantity) AS 총주문금액
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN products p ON o.product_id = p.product_id
    GROUP BY c.customer_id, c.name
    ORDER BY 총주문금액 DESC;   

-- DB 호환성과 엄격한 SQL 표준을 유지하기 위해, 
-- SELECT 절에 조회할 비집계 컬럼이 있다면 GROUP BY c.customer_id, c.name처럼 
-- 모두 명시해 주는 습관을 갖는 것이 훨씬 안전합니다.    

SELECT
    category,
    COUNT(*) AS 상품수,
    AVG(price) AS 평균가격,
    SUM(stock) AS 총재고
FROM products
GROUP BY category
HAVING AVG(price) >= 100000
ORDER BY 평균가격 DESC;

SELECT 
    category AS 카테고리,
    name AS 상품명,
    price AS 가격,
    DENSE_RANK() OVER (
        PARTITION BY category 
        ORDER BY price DESC
    ) AS 카테고리내_가격순위
FROM products;

SELECT 
    o.customer_id AS 고객ID,
    c.name AS 고객명,
    o.order_date AS 주문일자,
    (p.price * o.quantity) AS 주문금액,
    -- 고객별(PARTITION BY) 주문일시 순으로(ORDER BY) 누적 합계 계산
    SUM(p.price * o.quantity) OVER (
        PARTITION BY o.customer_id 
        ORDER BY o.order_date
    ) AS 누적구매금액
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;

SELECT 
    a.name, 
    b.total_amount
FROM customers a
JOIN (
    SELECT 
        o.customer_id, 
        SUM(p.price * o.quantity) AS total_amount
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY o.customer_id
) b ON a.customer_id = b.customer_id;

WITH customer_order_totals AS (
    SELECT 
        o.customer_id,
        SUM(p.price * o.quantity) AS total_amount
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY o.customer_id
)
SELECT 
    c.name,
    cot.total_amount
FROM customers c
JOIN customer_order_totals cot ON c.customer_id = cot.customer_id;

WITH
-- 첫 번째 CTE: 고객별 총 주문금액
CustomerSpend AS (
	SELECT 
        o.customer_id,
        SUM(p.price * o.quantity) AS total_spend
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY o.customer_id
),
-- 두 번째 CTE: 첫 번째 CTE를 참조하여 100만 원 이상 구매한 VIP만 추출
VipCustomers AS (
    SELECT customer_id, total_spend
    FROM CustomerSpend
    WHERE total_spend >= 1000000
)
-- 메인 쿼리
SELECT c.name, v.total_spend
FROM VipCustomers v
JOIN customers c ON v.customer_id = c.customer_id;

-- 총 구매 금액이 10만원 이상인 우수 고객의 주문 목록 조회
WITH UserTotalSpend AS (
    SELECT 
        o.customer_id,
        SUM(p.price * o.quantity) AS total_spend
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY o.customer_id
    HAVING total_spend >= 100000
)
SELECT 
    c.name AS 고객명,
    uts.total_spend AS 총구매액,
    p.name AS 구매상품,
    o.quantity AS 수량
FROM UserTotalSpend uts
JOIN customers c ON uts.customer_id = c.customer_id
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id;

UPDATE customers
    SET city = '광주'
    WHERE customer_id = 3;
    
select * from customers;    
    
UPDATE customers
    SET city = '대전', phone = '010-9999-0000'
    WHERE name = '박민준';
    
UPDATE products
    SET price = price * 1.1
    WHERE stock >= 100; 
    
DELETE FROM orders WHERE order_id = 5;   
DELETE FROM orders WHERE status = '배송완료'; 
DELETE FROM orders;
TRUNCATE TABLE orders;

START TRANSACTION;
INSERT INTO orders (customer_id, product_id, quantity) VALUES (1, 2, 1);
UPDATE products SET stock = stock - 1 WHERE product_id = 2;
COMMIT;     -- 트랜잭션 확정 (영구 저장)

START TRANSACTION;
    INSERT INTO customers (name, email, age) VALUES ('테스트1', 'test1@test.com', 20);
    SAVEPOINT sp1;
    INSERT INTO customers (name, email, age) VALUES ('테스트2', 'test2@test.com', 21);
    ROLLBACK TO sp1;   -- sp1 이후 작업만 취소
COMMIT;    -- 테스트1만 저장됨

CREATE INDEX idx_city ON customers(city);
CREATE INDEX idx_category ON products(category);
CREATE INDEX idx_name_city ON customers(name, city);
SHOW INDEX FROM customers;
DROP INDEX idx_city ON customers;
EXPLAIN SELECT * FROM customers WHERE city = '서울';
SELECT * FROM customers WHERE city = '서울';

CREATE VIEW v_order_summary AS
    SELECT c.name AS 고객명,
    p.name AS 상품명,
    o.quantity AS 수량,
    p.price * o.quantity AS 주문금액,
    o.status AS 상태
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    INNER JOIN products p ON o.product_id = p.product_id;
    
SELECT * FROM v_order_summary;
SELECT * FROM v_order_summary WHERE 상태 = '주문완료';    
DROP VIEW IF EXISTS v_order_summary;

CREATE USER 'student'@'localhost' IDENTIFIED BY 'pass1234!';
GRANT ALL PRIVILEGES ON shopdb.* TO 'student'@'localhost';
GRANT SELECT ON shopdb.* TO 'student'@'localhost';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'student'@'localhost';

REVOKE ALL PRIVILEGES ON shopdb.* FROM 'student'@'localhost';
-- REVOKE ALL, GRANT OPTION FROM 'student'@'localhost'; -- 전체 회수 시

DROP USER 'student'@'localhost';

SELECT name, age, IF(age >= 20, '성인', '미성년자') AS 구분
    FROM customers;
    
SELECT name, city,
    CASE city
        WHEN '서울' THEN '수도권'
        WHEN '인천' THEN '수도권'
    ELSE '기타'
    END AS 지역구분
FROM customers;    

SELECT name, IFNULL(phone, '번호없음') AS 전화번호
    FROM customers;
    
SELECT * FROM products
    WHERE price = (SELECT MAX(price) FROM products);  
    
SELECT name FROM customers
    WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders);    
    
SELECT name FROM customers
    WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);  
    
SELECT 고객명, 총주문금액
FROM (
    SELECT c.name AS 고객명,
         SUM(p.price * o.quantity) AS 총주문금액
    FROM orders o
       JOIN customers c ON o.customer_id = c.customer_id
       JOIN products p ON o.product_id = p.product_id
      GROUP BY c.customer_id
) AS sub
WHERE 총주문금액 >= 500000;    

SELECT p.name          AS 상품명,
       p.category      AS 카테고리,
       p.price         AS 단가,
       SUM(o.quantity) AS 총판매수량,
       SUM(p.price * o.quantity) AS 총매출액
FROM products p
  LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.name, p.category, p.price
ORDER BY 총매출액 DESC;

SELECT name AS 상품명, stock AS 재고수량,
       '⚠️ 재고 부족' AS 알림
FROM products
WHERE stock < 70
ORDER BY stock ASC;


SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS 주문월,
       COUNT(o.order_id)                  AS 주문건수,
       SUM(p.price * o.quantity)           AS 월매출액
FROM orders o
  JOIN products p ON o.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY 주문월;

SELECT c.name                          AS 고객명,
       c.city                          AS 지역,
       COUNT(o.order_id)               AS 주문건수,
       SUM(p.price * o.quantity)        AS 총구매금액,
       CASE
         WHEN SUM(p.price * o.quantity) >= 1000000 THEN 'VIP'
         WHEN SUM(p.price * o.quantity) >= 500000  THEN 'GOLD'
         ELSE 'NORMAL'
       END AS 등급
FROM customers c
  JOIN orders   o ON c.customer_id = o.customer_id
  JOIN products p ON o.product_id  = p.product_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY 총구매금액 DESC;

SELECT 
    *
FROM
    customers;
    
SELECT name, email, city FROM customers;   
SELECT name AS 고객명, email AS 이메일 FROM customers;
SELECT DISTINCT city FROM customers;
SELECT * FROM customers WHERE age >= 30;
SELECT name, city FROM customers WHERE city = '서울';
SELECT * FROM customers WHERE city = '서울' AND age >= 25;
SELECT * FROM customers WHERE city = '서울' OR city = '부산';
SELECT * FROM customers WHERE age BETWEEN 25 AND 35;SELECT * FROM shopdb.orders LIMIT 0, 1000