WITH RECURSIVE
    -- 1. Normalize and seed each description
    raw AS (
        SELECT
            RouteTextId,
            LOWER(REGEXP_REPLACE(ExtendedDesc, '[^A-Za-z0-9 ]+', '')) AS rest
        FROM RouteDesc
    ),
    -- 2. Recursively split off the first word from the remaining text
    split AS (
        SELECT
            RouteTextId,
            TRIM(SUBSTRING_INDEX(rest,' ',1))                AS word,
            TRIM(SUBSTRING(rest,
                           CHAR_LENGTH(SUBSTRING_INDEX(rest,' ',1)) + 2)
            )                                                AS rest
        FROM raw
        UNION ALL
        SELECT
            RouteTextId,
            TRIM(SUBSTRING_INDEX(rest,' ',1)),
            TRIM(SUBSTRING(rest,
                           CHAR_LENGTH(SUBSTRING_INDEX(rest,' ',1)) + 2)
            )
        FROM split
        WHERE rest <> ''
    ),
    -- 3. Count occurrences per word (only words ≥ 4 chars)
    word_counts AS (
        SELECT
            word,
            COUNT(*) AS freq
        FROM split
        WHERE word <> '' AND CHAR_LENGTH(word) >= 4
        GROUP BY word
    ),
    -- 4. Compute total token count
    totals AS (
        SELECT SUM(freq) AS total_tokens FROM word_counts
    )
SELECT
    wc.word,
    wc.freq,
    ROUND(wc.freq / t.total_tokens * 100, 2) AS pct_of_total
FROM word_counts AS wc
         CROSS JOIN totals AS t
         LEFT JOIN INFORMATION_SCHEMA.INNODB_FT_DEFAULT_STOPWORD AS sw
                   ON sw.value = wc.word
WHERE sw.value IS NULL
  AND wc.freq / t.total_tokens > 0.01
ORDER BY pct_of_total DESC
LIMIT 30;



ALTER TABLE RouteDesc
    DROP INDEX ft_route_desc,
    ADD FULLTEXT INDEX ft_route_desc (ExtendedDesc);

show index from RouteDesc;

SELECT *
FROM RouteDesc
WHERE MATCH(ExtendedDesc) AGAINST('visits' IN NATURAL LANGUAGE MODE);
