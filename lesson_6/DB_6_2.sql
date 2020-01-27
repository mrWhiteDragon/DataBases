/*
2)Проанализировать запросы, которые выполнялись на занятии, определить возможные корректировки и/или улучшения (JOIN пока не применять)
*/

-- Выберем id друзей
SELECT * FROM friendship WHERE user_id = 1 OR friend_id = 1;

-- В один столбец
SELECT friend_id AS id FROM friendship WHERE user_id = 1
UNION
SELECT user_id AS id FROM friendship WHERE friend_id = 1

-- Выбираем id отправителей сообщений
SELECT from_user_id FROM messages 
  WHERE to_user_id = 1
    AND from_user_id IN (
      SELECT friend_id AS id FROM friendship WHERE user_id = 1
      UNION
      SELECT user_id AS id FROM friendship WHERE friend_id = 1
    );

-- Добавляем имя друга
SELECT (SELECT CONCAT(first_name, '', last_name) FROM users WHERE id = from_user_id) AS friend
 FROM messages
   WHERE to_user_id = 1
     AND from_user_id IN (
       SELECT friend_id AS id FROM friendship WHERE user_id = 1
       UNION
       SELECT user_id AS id FROM friendship WHERE friend_id = 1
     );
        
-- Добавляем подсчет и сортировку
SELECT (SELECT CONCAT(first_name, '', last_name) FROM users WHERE id = from_user_id) AS friend,
 COUNT(*) AS total_messages
 FROM messages
   WHERE to_user_id = 1
     AND from_user_id IN (
       SELECT friend_id AS id FROM friendship WHERE user_id = 1
       UNION
       SELECT user_id AS id FROM friendship WHERE friend_id = 1
     )
   GROUP BY messages.from_user_id
   ORDER BY total_messages DESC
   LIMIT 1;
