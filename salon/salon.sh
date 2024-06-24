#!/bin/bash

PSQL="psql -X --username=postgres --dbname=salon --tuples-only -c"

# Display the list of services
function display_services() {
  echo -e "\nServices:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Prompt user to enter service ID
function get_service_id() {
  while true
  do
    display_services
    echo -e "\nPlease select a service by entering the corresponding number:"
    read SERVICE_ID_SELECTED

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      echo -e "\nInvalid service ID. Please try again."
    else
      break
    fi
  done
}


get_service_id

echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nNew customer! Please enter your name:"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
else
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi

echo -e "\nPlease enter a time for the appointment:"
read SERVICE_TIME

# Insert the appointment
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//')
CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *//;s/ *$//')
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
