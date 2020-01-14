-- 3)Переписать запросы, заданые к ДЗ урока 6 с использованием JOIN (четыре запроса).
-- ДЗ к уроку 8


-- 1.Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех
-- общался с нашим пользоваетелем.

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
 



