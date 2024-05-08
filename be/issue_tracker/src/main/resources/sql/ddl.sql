use issue_tracker;
drop table if exists ISSUE_LABEL, ISSUE_MILESTONE, LABEL, MILESTONE, COMMENT, ISSUE, USERS;

create table USERS
(
    id          varchar(255) primary key,
    password    varchar(255),
    name        varchar(255)                       not null,
    created_at  timestamp                          not null,
    profile_img varchar(255),
    type        enum ('normal', 'github', 'apple') not null default 'normal'
);

create table ISSUE
(
    id               bigint auto_increment primary key,
    user_id          varchar(255)           not null,
    title            varchar(255)           not null,
    comment          text                   not null,
    created_at       timestamp              not null,
    last_modified_at timestamp              not null default current_timestamp,
    status           enum ('open', 'close') not null default 'open',
    foreign key (user_id) references USERS (id)
);

create table LABEL
(
    id          bigint auto_increment primary key,
    name        varchar(255) not null,
    description text         not null,
    created_at  timestamp    not null,
    color       varchar(255) not null
);

create table MILESTONE
(
    id          bigint auto_increment primary key,
    name        varchar(255) not null,
    description text         not null,
    created_at  timestamp    not null,
    deadline    timestamp
);

create table COMMENT
(
    id               bigint auto_increment primary key,
    user_id          varchar(255) not null,
    issue_id         bigint       not null,
    created_at       timestamp    not null,
    last_modified_at timestamp    not null default current_timestamp,
    hasEmoji         boolean      not null default false,
    foreign key (user_id) references USERS (id),
    foreign key (issue_id) references ISSUE (id)
);

create table ISSUE_LABEL
(
    id       bigint auto_increment primary key,
    issue_id bigint,
    label_id bigint,
    foreign key (issue_id) references ISSUE (id),
    foreign key (label_id) references LABEL (id)
);

create table ISSUE_MILESTONE
(
    id           bigint auto_increment primary key,
    issue_id     bigint,
    milestone_id bigint,
    foreign key (issue_id) references ISSUE (id),
    foreign key (milestone_id) references MILESTONE (id)
);