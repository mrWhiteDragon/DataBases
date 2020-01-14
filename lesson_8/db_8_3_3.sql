-- 3)Переписать запросы, заданые к ДЗ урока 6 с использованием JOIN
--  (четыре запроса).

-- 3.Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT profiles.sex AS SEX, 
  COUNT(likes.id) AS total_likes
  FROM likes
    JOIN profiles
      ON likes.user_id = profiles.user_id
    GROUP BY profiles.sex
    ORDER BY total_likes DESC
    LIMIT 1;


