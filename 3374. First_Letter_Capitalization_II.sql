WITH RECURSIVE positions AS (
    SELECT
        content_id,
        content_text,
        1 AS pos
    FROM user_content

    UNION ALL

    SELECT
        content_id,
        content_text,
        pos + 1
    FROM positions
    WHERE pos < CHAR_LENGTH(content_text)
),

words AS (
    SELECT
        content_id,
        content_text,
        pos,
        SUBSTRING(content_text, pos, 1) AS ch,
        SUBSTRING(content_text, pos - 1, 1) AS prev_ch,
        CONCAT(
            SUBSTRING_INDEX(
                SUBSTRING(content_text, 1, pos - 1),
                ' ', -1
            ),
            SUBSTRING_INDEX(
                SUBSTRING(content_text, pos),
                ' ', 1
            )
        ) AS current_word
    FROM positions
),

converted AS (
    SELECT
        content_id,
        content_text,
        pos,
        CASE
            WHEN NOT REGEXP_LIKE(current_word, '^[A-Za-z]')
                THEN ch

            WHEN REGEXP_LIKE(
                current_word,
                '^[A-Za-z]+(-[A-Za-z]+)+$'
            )
            AND (pos = 1 OR prev_ch IN (' ', '-'))
                THEN UPPER(ch)

            WHEN pos = 1 OR prev_ch = ' '
                THEN UPPER(ch)

            ELSE LOWER(ch)
        END AS new_char
    FROM words
)

SELECT
    content_id,
    content_text AS original_text,
    GROUP_CONCAT(new_char ORDER BY pos SEPARATOR '') AS converted_text
FROM converted
GROUP BY content_id, content_text;
