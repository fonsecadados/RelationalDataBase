#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

PERMISSION="chmod +x queries.sh"
echo "$($PERMISSION)"
echo "$($PSQL "DROP TABLE IF EXISTS teams, games")"
echo "$($PSQL "CREATE TABLE teams(team_id SERIAL PRIMARY KEY, name VARCHAR(225) UNIQUE NOT NULL)")"

echo "$($PSQL "CREATE TABLE games(
game_id SERIAL PRIMARY KEY,
year INT NOT NULL,
round VARCHAR(225) NOT NULL,
winner_id INT NOT NULL,
opponent_id INT NOT NULL,
winner_goals INT NOT NULL,
opponent_goals INT NOT NULL,
FOREIGN KEY (winner_id) REFERENCES teams(team_id),
FOREIGN KEY (opponent_id) REFERENCES teams(team_id))")"

echo "$($PSQL "
INSERT INTO teams (name)
VALUES
    ('France'),
    ('Croatia'),
    ('Belgium'),
    ('England'),
    ('Russia'),
    ('Sweden'),
    ('Brazil'),
    ('Uruguay'),
    ('Colombia'),
    ('Switzerland'),
    ('Japan'),
    ('Mexico'),
    ('Denmark'),
    ('Spain'),
    ('Portugal'),
    ('Argentina'),
    ('Germany'),
    ('Netherlands'),
    ('Costa Rica'),
    ('Chile'),
    ('Nigeria'),
    ('Algeria'),
    ('Greece'),
    ('United States')")"

GAMES="games.csv"
DATA=$(cat "$GAMES")

echo "$DATA" | while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do

    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
           SELECT $year, '$round', winner.team_id, opponent.team_id, $winner_goals, $opponent_goals
           FROM teams AS winner, teams AS opponent
           WHERE winner.name = '$winner' AND opponent.name = '$opponent';"
done
