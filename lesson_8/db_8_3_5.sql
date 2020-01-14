-- 3)Переписать запросы, заданые к ДЗ урока 6 с использованием JOIN
--  (четыре запроса).

-- 5.Посмотрим почему нужен DISTINCT 
 SELECT users.id AS users_id,
  messages.id AS messages_id, 
  likes.id AS llikes_id, 
  media.id AS medias_id
  FROM users
    LEFT JOIN messages 
      ON users.id = messages.from_user_id
    LEFT JOIN likes
      ON users.id = likes.user_id
    LEFT JOIN media
      ON users.id = media.user_id
  WHERE users.id = 21; 
