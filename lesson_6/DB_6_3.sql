-- 3)Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

-- Смотрим типы для лайков 
SELECT * FROM target_types;

-- Выбираем профили с сортировкой по дате рождения
SELECT * FROM profiles ORDER BY birthday DESC LIMIT 10;

-- Выбираем лайки по типу пользователь
SELECT * FROM likes WHERE target_type_id = 2;

-- Объединяем, но так не работает
SELECT * FROM likes WHERE target_type_id = 2
  AND target_id IN (
    SELECT * FROM profiles ORDER BY birthday DESC LIMIT 10
  );

 -- Идем обходным путем
SELECT target_id, COUNT(*) FROM likes
  WHERE target_type_id = 2
    AND target_id IN (SELECT * FROM (
      SELECT * FROM profiles ORDER BY birthday DESC LIMIT 10
    ) AS sorted_profiles )
    GROUP BY target_id;
   
  -- Суммируем для всех пользователей
SELECT SUM(likes_per_user) AS likes_total FROM (
  SELECT COUNT(*) AS like_per_user 
    FROM likes
      WHERE target_type_id = 2
        AND target_id IN (
          SELECT * FROM (
            SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10
          ) AS sorted_profiles 
        )
      GROUP BY target_id
) AS counted_likes;
