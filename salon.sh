#!/bin/bash
PSQL="psql -X --username=freecodecamp --tuples-only --dbname=salon -c"

echo -e "\n\n ~~~~~ SUPER SALON ~~~~~ \n\nWelcome to Super Salon"
echo -e "\nHow can I help you?"
NEW_APPOINTMENT() {

  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "\nSelect what service you would like."
  SERVICES_AVAILABLE=$($PSQL "SELECT * FROM services")
  echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR1 SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then 
    NEW_APPOINTMENT "Invalid Service Selection. Try Again."
  fi

  # Check if service exists
  SERVICE_REQUESTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_REQUESTED ]]; then 
    NEW_APPOINTMENT "Invalid Service Selection. Try Again."
  fi

  # Get customer's phone number
  echo -e "\nEnter Phone Number:"
  read CUSTOMER_PHONE

  # Check if user exists
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]; then 
    echo -e "\nEnter Name:"
    read CUSTOMER_NAME

    NEW_CUSTOMER_RESULTS=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    
    # Reset CUSTOMER_ID to the new customer_id after adding the new customer
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi

  echo -e "\nEnter Service Time:"
  read SERVICE_TIME

  NEW_APPT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
  exit 0
}

NEW_APPOINTMENT