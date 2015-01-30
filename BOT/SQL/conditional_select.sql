PROBLEM
SELECT
    challenger_name as name,
    IF(challenger_timeout > challenged_timeout,
        (SET  wins + 1),
        NULL) as wins,
    IF(challenger_timeout < challenged_timeout,
        (SET  lose + 1),
        NULL) as lose,
    IF(challenger_timeout = challenged_timeout,
        (SET  draw + 1),
        NULL) as draw
FROM time_trial_challenge
GROUP by challenger_name ORDER by wins DESC";


SOLUTION
SUM(challenger_timeout > challenged_timeout) as wins
