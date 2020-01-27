/* 5)Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети. */

SELECT CONCAT(first_name, ' ', last_name) AS user,
    (SELECT COUNT(*) FROM likes WHERE likes.user_id = users.id) +
    (SELECT COUNT(*) FROM media WHERE media.user_id = users.id) +
    (SELECT COUNT(*) FROM messages WHERE messages.from_user = users.id)
    AS overal_activity
    FROM users
    ORDER BY overal_activity
    LIMIT 10;

