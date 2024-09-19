---------- DDL Part II ----------

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(25) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    CONSTRAINT username_not_empty CHECK (username <> '')
);

CREATE TABLE topics (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) UNIQUE NOT NULL,
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT name_not_empty CHECK (name <> '')
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    url VARCHAR(3000),
    user_id INT REFERENCES users (id) ON DELETE SET NULL,
    topic_id INT NOT NULL REFERENCES topics (id) ON DELETE CASCADE,
    text_content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT title_not_empty CHECK (title <> ''),
    CONSTRAINT url_or_text CHECK ((url IS NOT NULL AND text_content IS NULL) OR (url IS NULL AND text_content IS NOT NULL))
);
CREATE INDEX idx_posts_title ON posts(title);
CREATE INDEX idx_posts_topic_id ON posts(topic_id);
CREATE INDEX idx_posts_url ON posts(url);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users (id) ON DELETE SET NULL,
    post_id INT NOT NULL REFERENCES posts (id) ON DELETE CASCADE,
    text_content TEXT NOT NULL,
    parent_comment_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT text_content_not_empty CHECK (text_content <> ''),
    FOREIGN KEY (parent_comment_id) REFERENCES comments (id) ON DELETE CASCADE
);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_parent_comment_id ON comments(parent_comment_id);

CREATE TABLE votes (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users (id) ON DELETE SET NULL,
    post_id INT NOT NULL REFERENCES posts (id) ON DELETE CASCADE,
    vote SMALLINT CHECK (vote = 1 OR vote = -1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_vote_per_user UNIQUE (user_id, post_id)
);
CREATE INDEX idx_votes_post_id ON votes(post_id);
CREATE INDEX idx_votes_user_id ON votes(user_id);
