drop table if exists ISSUE_HAS_ASSIGNEE, ISSUE_HAS_LABEL, USER_LIKES_COMMENT, COMMENT_FILE, COMMENT, ISSUE, LABEL, MILESTONE, USERS;

create table USERS
(
    id          varchar(255) primary key,
    password    varchar(255),
    name        varchar(255) not null,
    profile_img varchar(255),
    login_type  varchar(50)  not null default 'NORMAL',
    created_at  timestamp             default current_timestamp
);

create table MILESTONE
(
    id          bigint auto_increment primary key,
    name        varchar(255) unique not null,
    description text,
    deadline    date,
    user_id     varchar(255)        not null,
    created_at  timestamp default current_timestamp,
    foreign key (user_id) references USERS (id) ON DELETE CASCADE
);

create table LABEL
(
    id          bigint auto_increment primary key,
    name        varchar(255) unique not null,
    description text,
    color       varchar(7)          not null default '#ffffff',
    user_id     varchar(255)        not null,
    created_at  timestamp                    default current_timestamp,
    foreign key (user_id) references USERS (id) ON DELETE CASCADE
);

create table ISSUE
(
    id               bigint auto_increment primary key,
    user_id          varchar(255) not null,
    milestone_id     bigint,
    title            varchar(255) not null,
    status           varchar(50)  not null default 'OPEN',
    last_modified_at timestamp             default current_timestamp,
    created_at       timestamp             default current_timestamp,
    foreign key (user_id) references USERS (id) ON DELETE CASCADE,
    foreign key (milestone_id) references MILESTONE (id) ON DELETE SET NULL
);

create table COMMENT
(
    id               bigint auto_increment primary key,
    issue_id         bigint,
    user_id          varchar(255),
    content          text,
    last_modified_at timestamp default current_timestamp,
    created_at       timestamp default current_timestamp,
    foreign key (issue_id) references ISSUE (id) ON DELETE CASCADE,
    foreign key (user_id) references USERS (id) ON DELETE CASCADE
);

create table COMMENT_FILE
(
    id         bigint auto_increment primary key,
    comment_id bigint,
    file_url   varchar(255) not null,
    foreign key (comment_id) references COMMENT (id) ON DELETE CASCADE
);

create table USER_LIKES_COMMENT
(
    id         bigint auto_increment primary key,
    user_id    varchar(255),
    comment_id bigint,
    foreign key (user_id) references USERS (id) ON DELETE CASCADE,
    foreign key (comment_id) references COMMENT (id) ON DELETE CASCADE,
    unique (user_id, comment_id)
);

create table ISSUE_HAS_LABEL
(
    id       bigint auto_increment primary key,
    issue_id bigint,
    label_id bigint,
    sequence int default 0,
    foreign key (issue_id) references ISSUE (id) ON DELETE CASCADE,
    foreign key (label_id) references LABEL (id) ON DELETE CASCADE,
    unique (issue_id, label_id)
);

create table ISSUE_HAS_ASSIGNEE
(
    id          bigint auto_increment primary key,
    issue_id    bigint,
    assignee_id varchar(255),
    sequence int default 0,
    foreign key (issue_id) references ISSUE (id) ON DELETE CASCADE,
    foreign key (assignee_id) references USERS (id) ON DELETE CASCADE,
    unique (issue_id, assignee_id)
);

CREATE INDEX comment_issue_idx ON COMMENT (issue_id);
CREATE INDEX assignee_issue_idx ON ISSUE_HAS_ASSIGNEE (issue_id);
CREATE INDEX label_issue_idx ON ISSUE_HAS_LABEL (issue_id);