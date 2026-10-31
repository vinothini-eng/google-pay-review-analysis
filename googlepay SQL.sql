-- ============================================================
-- GOOGLE PAY DATA ANALYSIS PROJECT
-- NLP DATASET - COMPLETE MYSQL SCRIPT
-- ============================================================

-- ============================================================
-- STEP 1: CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS ph;

USE ph;


-- ============================================================
-- STEP 2: CREATE TABLE
-- ============================================================

DROP TABLE IF EXISTS googlepay_review;

CREATE TABLE googlepay_review (
    reviewId VARCHAR(500),
    userName VARCHAR(500),
    content TEXT,
    score INT,
    thumbsUpCount INT,
    reviewCreatedVersion VARCHAR(255),
    `at` DATETIME,
    replyContent TEXT,
    repliedAt DATETIME,
    sentiment VARCHAR(50),
    year INT,
    month INT,
    year_month VARCHAR(20),
    has_reply INT,
    clean_text TEXT,
    word_count INT,
    character_count INT,
    nlp_sentiment VARCHAR(50),
    sentiment_score DECIMAL(10,5)
);


-- ============================================================
-- STEP 3: CHECK TABLE
-- ============================================================

SHOW TABLES;

DESCRIBE googlepay_review;


-- ============================================================
-- STEP 4: ENABLE LOCAL INFILE
-- ============================================================

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';


-- ============================================================
-- STEP 5: IMPORT NLP DATASET
-- ============================================================

-- If LOCAL INFILE is enabled, run this.
-- Otherwise use:
-- MySQL Workbench → Table Data Import Wizard

LOAD DATA LOCAL INFILE
'C:/Users/Vinothini/Documents/UPI/GooglePayIndia_NLP.csv'

INTO TABLE googlepay_review

FIELDS TERMINATED BY ','
ENCLOSED BY '"'

LINES TERMINATED BY '\r\n'

IGNORE 1 ROWS

(
    reviewId,
    userName,
    content,
    score,
    thumbsUpCount,
    reviewCreatedVersion,
    `at`,
    replyContent,
    repliedAt,
    sentiment,
    year,
    month,

    has_reply,
    clean_text,
    word_count,
    character_count,
    nlp_sentiment,
    sentiment_score
);


-- ============================================================
-- STEP 6: VERIFY DATA
-- ============================================================

SELECT COUNT(*) AS total_reviews
FROM googlepay_review;


SELECT *
FROM googlepay_review
LIMIT 10;


-- ============================================================
-- STEP 7: DATA QUALITY CHECK
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(reviewId) AS review_ids,
    COUNT(userName) AS usernames,
    COUNT(content) AS review_content,
    COUNT(score) AS ratings,
    COUNT(thumbsUpCount) AS thumbs_up,
    COUNT(`at`) AS review_dates,
    COUNT(nlp_sentiment) AS nlp_sentiments,
    COUNT(sentiment_score) AS sentiment_scores
FROM googlepay_review;


-- ============================================================
-- STEP 8: TOTAL REVIEWS
-- ============================================================

SELECT
    COUNT(*) AS total_reviews
FROM googlepay_review;


-- ============================================================
-- STEP 9: AVERAGE RATING
-- ============================================================

SELECT
    ROUND(AVG(score), 2) AS average_rating
FROM googlepay_review;


-- ============================================================
-- STEP 10: RATING DISTRIBUTION
-- ============================================================

SELECT
    score AS rating,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM googlepay_review),
        2
    ) AS percentage
FROM googlepay_review
GROUP BY score
ORDER BY score;


-- ============================================================
-- STEP 11: SENTIMENT DISTRIBUTION
-- ============================================================

SELECT
    nlp_sentiment,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM googlepay_review),
        2
    ) AS percentage
FROM googlepay_review
GROUP BY nlp_sentiment
ORDER BY review_count DESC;


-- ============================================================
-- STEP 12: SENTIMENT VS RATING
-- ============================================================

SELECT
    nlp_sentiment,
    COUNT(*) AS review_count,
    ROUND(AVG(score), 2) AS average_rating
FROM googlepay_review
GROUP BY nlp_sentiment
ORDER BY average_rating DESC;


-- ============================================================
-- STEP 13: REVIEWS BY YEAR
-- ============================================================

SELECT
    year AS review_year,
    COUNT(*) AS review_count
FROM googlepay_review
WHERE year IS NOT NULL
GROUP BY year
ORDER BY year;


-- ============================================================
-- STEP 14: REVIEWS BY MONTH
-- ============================================================

SELECT
    year AS review_year,
    month AS review_month,
    COUNT(*) AS review_count
FROM googlepay_review
WHERE year IS NOT NULL
AND month IS NOT NULL
GROUP BY year, month
ORDER BY year, month;


-- ============================================================
-- STEP 15: AVERAGE RATING BY YEAR
-- ============================================================

SELECT
    year AS review_year,
    ROUND(AVG(score), 2) AS average_rating
FROM googlepay_review
WHERE year IS NOT NULL
GROUP BY year
ORDER BY year;


-- ============================================================
-- STEP 16: AVERAGE RATING BY MONTH
-- ============================================================

SELECT
    year AS review_year,
    month AS review_month,
    ROUND(AVG(score), 2) AS average_rating
FROM googlepay_review
WHERE year IS NOT NULL
AND month IS NOT NULL
GROUP BY year, month
ORDER BY year, month;


-- ============================================================
-- STEP 17: TOP 10 MOST-LIKED REVIEWS
-- ============================================================

SELECT
    score,
    thumbsUpCount,
    content
FROM googlepay_review
WHERE content IS NOT NULL
ORDER BY thumbsUpCount DESC
LIMIT 10;


-- ============================================================
-- STEP 18: AVERAGE THUMBS-UP BY RATING
-- ============================================================

SELECT
    score AS rating,
    COUNT(*) AS review_count,
    ROUND(AVG(thumbsUpCount), 2) AS average_thumbs_up
FROM googlepay_review
GROUP BY score
ORDER BY score;


-- ============================================================
-- STEP 19: TOP 10 APP VERSIONS
-- ============================================================

SELECT
    reviewCreatedVersion AS app_version,
    COUNT(*) AS review_count
FROM googlepay_review
WHERE reviewCreatedVersion IS NOT NULL
GROUP BY reviewCreatedVersion
ORDER BY review_count DESC
LIMIT 10;


-- ============================================================
-- STEP 20: APP VERSION PERFORMANCE
-- ============================================================

SELECT
    reviewCreatedVersion AS app_version,
    COUNT(*) AS review_count,
    ROUND(AVG(score), 2) AS average_rating
FROM googlepay_review
WHERE reviewCreatedVersion IS NOT NULL
GROUP BY reviewCreatedVersion
HAVING COUNT(*) >= 20
ORDER BY average_rating DESC;


-- ============================================================
-- STEP 21: REPLY ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS total_reviews,

    SUM(
        CASE
            WHEN has_reply = 1 THEN 1
            ELSE 0
        END
    ) AS replied_reviews,

    SUM(
        CASE
            WHEN has_reply = 0 THEN 1
            ELSE 0
        END
    ) AS unreplied_reviews

FROM googlepay_review;


-- ============================================================
-- STEP 22: RESPONSE RATE
-- ============================================================

SELECT
    ROUND(
        SUM(
            CASE
                WHEN has_reply = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS response_rate
FROM googlepay_review;


-- ============================================================
-- STEP 23: RESPONSE RATE BY RATING
-- ============================================================

SELECT
    score AS rating,
    COUNT(*) AS total_reviews,

    SUM(
        CASE
            WHEN has_reply = 1 THEN 1
            ELSE 0
        END
    ) AS replied_reviews,

    ROUND(
        SUM(
            CASE
                WHEN has_reply = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS response_rate

FROM googlepay_review

GROUP BY score
ORDER BY score;


-- ============================================================
-- STEP 24: MOST NEGATIVE REVIEWS
-- ============================================================

SELECT
    score,
    sentiment_score,
    content
FROM googlepay_review
WHERE LOWER(nlp_sentiment) = 'negative'
ORDER BY sentiment_score ASC
LIMIT 10;


-- ============================================================
-- STEP 25: MOST POSITIVE REVIEWS
-- ============================================================

SELECT
    score,
    sentiment_score,
    content
FROM googlepay_review
WHERE LOWER(nlp_sentiment) = 'positive'
ORDER BY sentiment_score DESC
LIMIT 10;


-- ============================================================
-- STEP 26: AVERAGE SENTIMENT SCORE BY RATING
-- ============================================================

SELECT
    score AS rating,
    ROUND(AVG(sentiment_score), 3) AS average_sentiment
FROM googlepay_review
GROUP BY score
ORDER BY score;


-- ============================================================
-- STEP 27: PAYMENT ISSUES
-- ============================================================

SELECT
    COUNT(*) AS payment_issue_reviews
FROM googlepay_review
WHERE LOWER(content) LIKE '%payment%'
   OR LOWER(content) LIKE '%transaction%'
   OR LOWER(content) LIKE '%transfer%';


-- ============================================================
-- STEP 28: REFUND ISSUES
-- ============================================================

SELECT
    COUNT(*) AS refund_issue_reviews
FROM googlepay_review
WHERE LOWER(content) LIKE '%refund%'
   OR LOWER(content) LIKE '%refunded%';


-- ============================================================
-- STEP 29: TECHNICAL ISSUES
-- ============================================================

SELECT
    COUNT(*) AS technical_issue_reviews
FROM googlepay_review
WHERE LOWER(content) LIKE '%error%'
   OR LOWER(content) LIKE '%bug%'
   OR LOWER(content) LIKE '%crash%'
   OR LOWER(content) LIKE '%problem%'
   OR LOWER(content) LIKE '%issue%';


-- ============================================================
-- STEP 30: NEGATIVE PAYMENT REVIEWS
-- ============================================================

SELECT
    COUNT(*) AS negative_payment_reviews
FROM googlepay_review
WHERE score <= 2
AND (
    LOWER(content) LIKE '%payment%'
    OR LOWER(content) LIKE '%transaction%'
    OR LOWER(content) LIKE '%transfer%'
);


-- ============================================================
-- STEP 31: PAYMENT ISSUES BY SENTIMENT
-- ============================================================

SELECT
    nlp_sentiment,
    COUNT(*) AS payment_issue_reviews
FROM googlepay_review
WHERE LOWER(content) LIKE '%payment%'
   OR LOWER(content) LIKE '%transaction%'
   OR LOWER(content) LIKE '%transfer%'
GROUP BY nlp_sentiment
ORDER BY payment_issue_reviews DESC;


-- ============================================================
-- STEP 32: ISSUES BY RATING
-- ============================================================

SELECT
    score AS rating,
    COUNT(*) AS issue_reviews
FROM googlepay_review
WHERE LOWER(content) LIKE '%error%'
   OR LOWER(content) LIKE '%problem%'
   OR LOWER(content) LIKE '%issue%'
   OR LOWER(content) LIKE '%payment%'
   OR LOWER(content) LIKE '%transaction%'
GROUP BY score
ORDER BY score;


-- ============================================================
-- STEP 33: AVERAGE WORD COUNT BY SENTIMENT
-- ============================================================

SELECT
    nlp_sentiment,
    COUNT(*) AS review_count,
    ROUND(AVG(word_count), 2) AS average_word_count
FROM googlepay_review
GROUP BY nlp_sentiment
ORDER BY average_word_count DESC;


-- ============================================================
-- STEP 34: LONGEST REVIEWS
-- ============================================================

SELECT
    score,
    word_count,
    character_count,
    content
FROM googlepay_review
WHERE content IS NOT NULL
ORDER BY word_count DESC
LIMIT 10;


-- ============================================================
-- STEP 35: HIGHEST SENTIMENT SCORES
-- ============================================================

SELECT
    score,
    nlp_sentiment,
    sentiment_score,
    content
FROM googlepay_review
ORDER BY sentiment_score DESC
LIMIT 10;


-- ============================================================
-- STEP 36: LOWEST SENTIMENT SCORES
-- ============================================================

SELECT
    score,
    nlp_sentiment,
    sentiment_score,
    content
FROM googlepay_review
ORDER BY sentiment_score ASC
LIMIT 10;


-- ============================================================
-- STEP 37: POSITIVE / NEUTRAL / NEGATIVE BY RATING
-- ============================================================

SELECT
    score AS rating,

    SUM(
        CASE
            WHEN LOWER(nlp_sentiment) = 'positive'
            THEN 1 ELSE 0
        END
    ) AS positive_reviews,

    SUM(
        CASE
            WHEN LOWER(nlp_sentiment) = 'neutral'
            THEN 1 ELSE 0
        END
    ) AS neutral_reviews,

    SUM(
        CASE
            WHEN LOWER(nlp_sentiment) = 'negative'
            THEN 1 ELSE 0
        END
    ) AS negative_reviews

FROM googlepay_review

GROUP BY score
ORDER BY score;


-- ============================================================
-- STEP 38: FINAL PROJECT KPI
-- ============================================================

SELECT

    COUNT(*) AS total_reviews,

    ROUND(AVG(score), 2) AS average_rating,

    SUM(
        CASE
            WHEN score = 5 THEN 1
            ELSE 0
        END
    ) AS five_star_reviews,

    SUM(
        CASE
            WHEN score = 4 THEN 1
            ELSE 0
        END
    ) AS four_star_reviews,

    SUM(
        CASE
            WHEN score = 3 THEN 1
            ELSE 0
        END
    ) AS three_star_reviews,

    SUM(
        CASE
            WHEN score = 2 THEN 1
            ELSE 0
        END
    ) AS two_star_reviews,

    SUM(
        CASE
            WHEN score = 1 THEN 1
            ELSE 0
        END
    ) AS one_star_reviews,

    SUM(
        CASE
            WHEN score >= 4 THEN 1
            ELSE 0
        END
    ) AS positive_reviews,

    SUM(
        CASE
            WHEN score = 3 THEN 1
            ELSE 0
        END
    ) AS neutral_reviews,

    SUM(
        CASE
            WHEN score <= 2 THEN 1
            ELSE 0
        END
    ) AS negative_reviews,

    SUM(
        CASE
            WHEN has_reply = 1 THEN 1
            ELSE 0
        END
    ) AS replied_reviews,

    SUM(
        CASE
            WHEN has_reply = 0 THEN 1
            ELSE 0
        END
    ) AS unreplied_reviews,

    ROUND(
        SUM(
            CASE
                WHEN has_reply = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS response_rate,

    ROUND(
        AVG(sentiment_score),
        3
    ) AS average_sentiment_score,

    ROUND(
        AVG(word_count),
        2
    ) AS average_word_count,

    ROUND(
        AVG(character_count),
        2
    ) AS average_character_count

FROM googlepay_review;


-- ============================================================
-- END OF GOOGLE PAY SQL ANALYSIS
-- ============================================================
SELECT COUNT(*) AS total_reviews
FROM googlepay_review;