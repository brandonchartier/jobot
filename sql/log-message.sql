INSERT INTO log (
  sent_to,
  sent_by,
  message
)
VALUES (
  :to,
  :by,
  :message
);
