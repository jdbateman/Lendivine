# Lendivine

## Summary
Lendivine is an iOS application targetted for an iPhone running iOS 8 and above. 
This application enables users to search for and make small loans to entrepreneurs around the world. Yeah baby!

## UI

The UI is comprised of 9 main view controllers.
0. Login view controller enables the user to login to the app or sign up for an account through the Kiva.org web interface.

Once the user has successfully Logged into the application 5 screens are available from a tab bar controller.
1. Loans - Displays a list of loans queried through the Kiva REST API.
2. Countries - Displays a list of countries queried through the RESTCountries API. Can be searched via a search bar.
3. Cart - Shows the loans added to the user's cart. Checkout the cart and get transferred to the Kiva.org web interface to complete the checkout process. 
4. My Loans - Shows all of the loans the user has made.
5. My Account - Displays account information for the logged in account. Enables the user to capture a profile image. (Unfortunately the kiva api does not contain a method to acquire the user account image from kiva.org.)

These view controllers provide additional detail:
6. Country Loans - Displays loans queried from the Kiva REST API for a specific country.
7. Loan Details - Displays additional information about a specific loan, including the location of the loanee on a map.
8. Map - Displas a group of loans on a map view. Individual loans are represented by annotations and callouts with images.


## Technical overview

The project is written in Swift.

Technical highlights:
Uses two REST apis: Kiva.org and RESTCountries.
Implements OAuth 1.x to authenticate with the kiva.org service.
UISearchController in Countries view controller enables search of view controller with a lot of data.
Swift exception handling is used.


