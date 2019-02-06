DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
	SELECT MAX(era)
	FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
	SELECT namefirst, namelast, birthyear
	FROM people
	WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
	SELECT namefirst, namelast, birthyear
	FROM people
	WHERE namefirst ~ '.* .*'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
	SELECT birthyear, AVG(height), COUNT(*)
	FROM people
	GROUP BY birthyear
	ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
        SELECT birthyear, AVG(height), COUNT(*)
        FROM people
        GROUP BY birthyear
	HAVING AVG(height) > 70
        ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
	SELECT p.namefirst, p.namelast, p.playerid, h.yearid
	FROM people p INNER JOIN halloffame h
	ON p.playerid = h.playerid AND h.inducted = 'Y'
	ORDER BY h.yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
	SELECT q.namefirst, q.namelast, q.playerid, s.schoolid, q.yearid
	FROM
		q2i q
	INNER JOIN
		schools s
		INNER JOIN
		collegeplaying c
		ON s.schoolid = c.schoolid AND s.schoolstate = 'CA'
	ON q.playerid = c.playerid
	ORDER BY q.yearid DESC, s.schoolid, c.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
	SELECT p.playerid, p.namefirst, p.namelast, c.schoolid
	FROM
		people p
		LEFT JOIN
		collegeplaying c
		ON p.playerid = c.playerid
	INNER JOIN
		q2i q
	ON q.playerid = p.playerid
	ORDER BY playerid DESC, schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
	SELECT p.playerid, p.namefirst, p.namelast, b.yearid, (b.h+b.h2b+2*b.h3b+3*b.hr)/CAST(b.ab AS FLOAT) as slg
	FROM batting b INNER JOIN people p
	ON p.playerid = b.playerid
	WHERE b.ab > 50
	ORDER BY slg DESC, yearid, playerid
	LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
	SELECT p.playerid, p.namefirst, p.namelast, SUM(b.h+b.h2b+2*b.h3b+3*b.hr)/SUM(CAST(b.ab AS FLOAT)) as lslg
	FROM batting b INNER JOIN people p
	ON p.playerid = b.playerid
	GROUP BY p.playerid
	HAVING SUM(b.ab) > 50
	ORDER BY lslg DESC, p.playerid
	LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
	WITH lslgs(playerid, namefirst, namelast, lslg) AS (
	        SELECT p.playerid, p.namefirst, p.namelast, SUM(b.h+b.h2b+2*b.h3b+3*b.hr)/SUM(CAST(b.ab AS FLOAT)) as lslg
	        FROM batting b INNER JOIN people p
	        ON p.playerid = b.playerid
	        GROUP BY p.playerid
	        HAVING SUM(b.ab) > 50
	)
	SELECT a.namefirst, a.namelast, a.lslg
	FROM lslgs a
	WHERE a.lslg > ALL(SELECT b.lslg FROM lslgs b WHERE b.playerid = 'mayswi01')
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
	SELECT s.yearid, MIN(s.salary), MAX(s.salary), AVG(s.salary), STDDEV(s.salary)
	FROM salaries s
	GROUP BY s.yearid
	ORDER BY s.yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
	WITH bins(binid, salary, width, min, max) AS (
		SELECT
		CASE
			WHEN FLOOR((s.salary-m.min+0.0)/(m.max-m.min)*10) > 9 THEN 9
			ELSE FLOOR((s.salary-m.min+0.0)/(m.max-m.min)*10)
		END,
		s.salary,
		(m.max-m.min)/10,
		m.min,
		m.max
		FROM
			salaries s
		INNER JOIN
			(SELECT MIN(t.salary) AS min, MAX(t.salary) AS max
			FROM salaries t
			WHERE t.yearid = 2016) m
		ON s.yearid = 2016)
	SELECT binid, binid*width+min, (binid+1)*width+min, COUNT(*)
	FROM bins b
	GROUP BY binid, width, min
	ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
	WITH stats(yearid, lsalary, hsalary, asalary) AS (
		SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
		FROM salaries
		GROUP BY yearid
	)
	SELECT b.yearid, b.lsalary-a.lsalary, b.hsalary-a.hsalary, b.asalary-a.asalary
	FROM stats a INNER JOIN stats b
	ON a.yearid+1 = b.yearid
	ORDER BY yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
	SELECT a.playerid, p.namefirst, p.namelast, a.salary, a.yearid
	FROM salaries a INNER JOIN people p
	ON a.playerid = p.playerid
	WHERE a.salary >= ALL(SELECT b.salary FROM salaries b WHERE a.yearid = b.yearid)
	AND (a.yearid = 2000 OR a.yearid = 2001)
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
	SELECT a.teamid, max(s.salary)-min(s.salary)
	FROM allstarfull a INNER JOIN salaries s
	ON a.yearid = s.yearid AND a.teamid = s.teamid AND a.playerid = s.playerid
	WHERE a.yearid = 2016
	GROUP BY a.teamid

;
