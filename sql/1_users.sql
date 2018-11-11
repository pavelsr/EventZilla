CREATE TABLE users (
  `id`                  INT NOT NULL AUTO_INCREMENT PRIMARY KEY   COMMENT 'Кэш ID пользователя',
  `parsed`              INT(11) NOT NULL DEFAULT UNIX_TIMESTAMP()     COMMENT 'обновлен',
  `vk_id`               INT NOT NULL                              COMMENT 'ID пользователя ВК',
  `bdate`               char(10)                                        COMMENT 'дата рождения',
  `age`                 INT(3)                                          COMMENT 'возраст',
  `sex`                 char(1)                                         COMMENT 'пол',
  `city`                TEXT                                   COMMENT 'текущий город',
  `faculty`             TEXT                                   COMMENT 'факультет',
  `cathedra`            TEXT                                   COMMENT 'кафедра',
  `status`              TEXT                                   COMMENT 'текущий статус при наличии',
  `vk_interests`        TEXT                                   COMMENT 'интересы согласно соотв полю профиля',
  `vk_all_group_names`  TEXT                                   COMMENT 'названия групп юзера в одну строчку',
  `vk_all_posts`        TEXT                                   COMMENT 'тексты всех постов юзера',
  `vk_all_group_descr`  TEXT                                   COMMENT 'названия групп юзера в одну строчку',
  `vk_posts_count`      INT(11)                                COMMENT 'количество постов на стене',
  UNIQUE KEY (vk_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci, COMMENT='Пользователи';
