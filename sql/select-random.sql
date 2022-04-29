SELECT * FROM log
WHERE sent_to = :sent
AND message LIKE :query
ORDER BY RANDOM()
LIMIT 1;
