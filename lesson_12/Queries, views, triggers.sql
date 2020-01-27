-- 1)Скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы):
-- Скрипт, позволяющий определить человека, который больше всех общался с данным пользователем.

SELECT (SELECT CONCAT(first_name, ' ', last_name) 
          FROM users 
            WHERE id = messages.from_user_id) AS friend_name, 
  COUNT(messages.id) AS total_messages 
  FROM users
    JOIN friendship friendship
      ON users.id = friendship.user_id
        OR users.id = friendship.friend_id
    JOIN messages
      ON messages.to_user_id = users.id
        AND (messages.from_user_id = friendship.friend_id
          OR messages.from_user_id = friendship.user_id)
  WHERE users.id = 1
  GROUP BY messages.from_user_id
  ORDER BY total_messages DESC
  LIMIT 1; 

-- 2)Представления (минимум 2):
-- Представление, которое считает количество букв в названии поста
CREATE OR REPLACE VIEW namepost (id, title, total) AS
SELECT id, title, LENGTH(title) FROM posts;

SELECT * FROM namepost ORDER BY total DESC;

-- Представление, которое выводит название name товарной
-- позиции из таблицы products и соответствующее название каталога name
-- из таблицы catalogs.

CREATE OR REPLACE VIEW products_catalogs AS
SELECT
  p.name AS product,
  c.name AS catalog
FROM
  products AS p
JOIN
  catalogs AS c
ON
  p.catalog_id = c.id;


-- 3)Хранимые процедуры / триггеры:

-- Создайтем хранимую функцию hello(), которая будет возвращать приветствие,
-- в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна
-- возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать
-- фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 —
-- "Доброй ночи".

USE lifemanager;

DROP FUNCTION IF EXISTS hello;

DELIMITER -

CREATE FUNCTION hello ()
RETURNS TINYTEXT NO SQL
BEGIN
  DECLARE hour INT;
  SET hour = HOUR(NOW());
  CASE
    WHEN hour BETWEEN 0 AND 5 THEN
      RETURN "Доброй ночи";
    WHEN hour BETWEEN 6 AND 11 THEN
      RETURN "Доброе утро";
    WHEN hour BETWEEN 12 AND 17 THEN
      RETURN "Добрый день";
    WHEN hour BETWEEN 18 AND 23 THEN
      RETURN "Добрый вечер";
  END CASE;
END-

DELIMITER ;
SELECT NOW(), hello ();


-- В таблице products есть два текстовых поля: name с названием товара и
-- description с его описанием. Допустимо присутствие обоих полей или одно из них.
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добеиваемся того, чтобы одно из этих полей или оба поля были заполнены.
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

DELIMITER //

CREATE TRIGGER validate_name_description_insert BEFORE INSERT ON products
FOR EACH ROW BEGIN
  IF NEW.name IS NULL AND NEW.description IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Both name and description are NULL';
  END IF;
END//

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  (NULL, NULL, 19900.00, 2)//

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Rules for building a customer base', 'Webtraining for sales managers', 19900.00, 2)//

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  (NULL, 'Webtraining for sales managers', 19900.00, 2)//

CREATE TRIGGER validate_name_description_update BEFORE UPDATE ON products
FOR EACH ROW BEGIN
  IF NEW.name IS NULL AND NEW.description IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Both name and description are NULL';
  END IF;
END//

