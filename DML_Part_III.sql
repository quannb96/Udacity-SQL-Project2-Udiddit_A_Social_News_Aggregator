---------- DML Part III ----------
-- Migrate Users 
INSERT INTO
    users (username, created_at, updated_at, last_login_at)
SELECT
    DISTINCT username,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CAST(NULL AS TIMESTAMP)
FROM
    bad_posts
UNION
SELECT
    DISTINCT username,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CAST(NULL AS TIMESTAMP)
FROM
    bad_comments
UNION
SELECT
    DISTINCT regexp_split_to_table(upvotes, ','),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CAST(NULL AS TIMESTAMP)
FROM
    bad_posts
UNION
SELECT
    DISTINCT regexp_split_to_table(downvotes, ','),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CAST(NULL AS TIMESTAMP)
FROM
    bad_posts;

-- Migrate Topics 
INSERT INTO
    topics (name, created_at, updated_at)
SELECT
    DISTINCT topic,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM
    bad_posts;

-- Migrate Posts 
INSERT INTO
    posts (
        title,
        url,
        user_id,
        topic_id,
        text_content,
        created_at,
        updated_at
    )
SELECT
    LEFT(b.title, 100),
    b.url,
    u.id,
    t.id,
    b.text_content,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM
    bad_posts b
    JOIN users u ON u.username = b.username
    JOIN topics t ON t.name = b.topic;

-- Migrate Comments 
INSERT INTO
    comments (
        user_id,
        post_id,
        text_content,
        created_at,
        updated_at
    )
SELECT
    u.id,
    p.id,
    bc.text_content,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM
    bad_comments bc
    JOIN users u ON u.username = bc.username
    JOIN posts p ON p.id = bc.post_id;

-- Migrate Votes 
WITH vote_data AS (
    SELECT
        b.id AS post_id,
        regexp_split_to_table(b.upvotes, ',') AS username,
        1 AS vote
    FROM
        bad_posts b
    UNION
    ALL
    SELECT
        b.id AS post_id,
        regexp_split_to_table(b.downvotes, ',') AS username,
        -1 AS vote
    FROM
        bad_posts b
)
INSERT INTO
    votes (user_id, post_id, vote, created_at, updated_at)
SELECT
    u.id,
    v.post_id,
    v.vote,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM
    vote_data v
    JOIN users u ON u.username = v.username
    JOIN posts p ON p.id = v.post_id;