-- 4)Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT CASE(sex)
        WHEN 'm' THEN 'man'
        WHEN 'f' THEN 'woman'
    END AS sex,
    COUNT(*) AS likes_count
      FROM (
        SELECT
	  user_id AS user,
	    (SELECT sex FROM profiles WHERE user_id = user) AS sex
	  FROM likes) dummy_table
   GROUP BY sex
   ORDER BY likes_count DESC
   LIMIT 1;
  

