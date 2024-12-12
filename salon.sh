#!/bin/bash

echo "Salon Appointment Scheduler Script Running"

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Fetch and display services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
echo -e "\n~~~~~ Available Services ~~~~~"
echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME; do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Prompt user for service selection in a loop
while [[ -z $SERVICE_NAME ]]; do
  # Display the services again each time
  echo -e "\n~~~~~ Available Services ~~~~~"
  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Ask for user input
  echo -e "\nPlease select a service by entering the service number:"
  read SERVICE_ID_SELECTED

  # Validate the input
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid selection. Please try again."
  fi
done

echo -e "\nYou selected $SERVICE_NAME."

# Prompt for customer phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if the customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_NAME ]]; then
  # If not found, ask for their name
  echo -e "\nI don't have a record for that phone number. What's your name?"
  read CUSTOMER_NAME
  
  # Insert the new customer into the database
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
fi

echo -e "\nHello, $CUSTOMER_NAME!"

# Prompt for appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert the appointment into the database
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES((SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

# Confirm the appointment
if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi