CREATE TABLE users (
  id                  MEDIUMINT NOT NULL AUTO_INCREMENT               COMMENT 'ID пользователя',
  registered          int(11)  NOT NULL DEFAULT UNIX_TIMESTAMP()      COMMENT 'current unix epoch timestamp in GMT+0 timezone',
  vk_id               MEDIUMINT NOT NULL                              COMMENT 'ID пользователя ВК',
  bdate               char(10)                                        COMMENT 'дата рождения',
  age                 int(3)                                          COMMENT 'возраст',
  sex                 char(1)                                         COMMENT 'пол',
  city                TEXT                                   COMMENT 'текущий город',
  faculty             TEXT                                   COMMENT 'факультет',
  cathedra            TEXT                                   COMMENT 'кафедра',
  vk_interests        TEXT                                   COMMENT 'интересы согласно соотв полю профиля',
  vk_all_group_names  TEXT                                   COMMENT 'названия групп юзера в одну строчку',
  vk_all_posts        TEXT                                   COMMENT 'тексты всех постов юзера',
  vk_all_group_descr  TEXT                                   COMMENT 'названия групп юзера в одну строчку',
  status              TEXT                                   COMMENT 'текущий статус при наличии',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci, COMMENT='Пользователи';
