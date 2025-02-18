#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear existing data
echo "$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")"

# Read from CSV file and insert data
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ "$YEAR" != "year" ]]
  then
    # Get winner ID, insert if not exists
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
    if [[ -z "$WINNER_ID" ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER');"
      WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
    fi

    # Get opponent ID, insert if not exists
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
    if [[ -z "$OPPONENT_ID" ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');"
      OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
    fi

    # Insert game details
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
  fi
done
