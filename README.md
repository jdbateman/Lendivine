# Lendivine

## Summary
Lendivine is an iOS application targetted for an iPhone running iOS 8 and above. 
This application enables users to search for and make small loans to entrepreneurs around the world. Yeah baby!

## UI

The UI is comprised of over a dozen view controllers. The main view controllers are listed below:

0. Login and Sign up view controller enable the user to login to the app or sign up for an account through the Kiva.org web interface.

Once the user has successfully Logged into the application 5 main screens are available from a tab bar controller.

1. Loans - Displays a list of loans queried through the Kiva REST API.

2. Countries - Displays a list of countries queried through the RESTCountries API. Can be searched via a search bar.

3. Cart - Shows the loans added to the user's cart. Checkout transfers the cart to Kiva.org via the rest api. An additional KivaCart view controller allows the user to complete the checkout process using the Kiva.org web interface. 

4. My Loans - Shows all of the loans the user has successfully purchased.

5. My Account - Displays account information for the logged in account. Enables the user to capture a profile image. (Unfortunately the kiva api does not contain a method to acquire the user account image from kiva.org.)

These view controllers provide additional detail:

6. Country Loans - Displays loans queried from the Kiva REST API for a specific country.

7. Loan Details - Displays additional information about a specific loan, including the location of the loanee on a map.

8. Map - Displas a group of loans on a map view. Individual loans are represented by annotations and callouts with images.


## Technical overview

The project is written and compiled in Swift 2.2 for an iOS base version of 8.0.

Technical highlights:
* Uses two REST apis: Kiva.org and RESTCountries.
* Implements OAuth 1.x to authenticate with the kiva.org service.
* UISearchController in Countries view controller enables search of view controller with a lot of data.
* Swift exception handling.
* MKMapView with annotations displaying a loan image in the annotation callout.
* Custom animation when loan is selected in the Loans view controller.
* Persists model data, particularly a user's CartItems. 
* Persists and refreshes Countries in core data to show how initialization performance can be enhanced while ensuring data is synced from the service.
* Implemented my own disk and memory cache of web image download to enhance performance.
* Implemented NSURLConnection based networking.
* Abstracted both REST APIs and the networking layer in separate classes following the separation of concerns design pattern.
* MVC design pattern.
* 


