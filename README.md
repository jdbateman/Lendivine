# Lendivine

## Summary
Lendivine is an iOS application that runs on an iPhone running iOS 8 and above. This application enables users to search for and make small loans to entrepreneurs around the world. Yeah baby!

## UI Overview
The UI is comprised of over a dozen view controllers. The main view controllers are listed below:

### Login & Signup Screens
* Login and Sign up view controller enable the user to login to the app or sign up for an account through the Kiva.org web interface.

### Main Tab Bar Screens
Once the user has successfully Logged into the application 5 main screens are available from a tab bar controller.

* Loans - Displays a list of loans queried through the Kiva REST API.

* Countries - Displays a list of countries queried through the RESTCountries API. Can be searched via a search bar.

* Cart - Shows the loans added to the user's cart. Checkout transfers the cart to Kiva.org via the rest api. An additional KivaCart view controller allows the user to complete the checkout process using the Kiva.org web interface. 

* My Loans - Shows all of the loans the user has successfully purchased.

* My Account - Displays account information for the logged in account. Enables the user to capture a profile image. (Unfortunately the kiva api does not contain a method to acquire the user account image from kiva.org.)

### Detail Screens
These view controllers provide additional detail:

* Country Loans - Displays loans queried from the Kiva REST API for a specific country.

* Loan Details - Displays additional information about a specific loan, including the location of the loan requester on a map.

* Map - Displays a group of loans on a map view. Individual loans are represented by annotations and callouts with images.


## Technical overview

The project is written and compiled in Swift 2.0 for an iOS base version of 8.4. using XCode version 7.1.

### Build Lendivine

To build the Lendivine project you will need Xcode 7.0 or later. The application deployment target is 8.4. Follow these steps to get the project running on your machine:

1. Clone the project to your local machine from Github using the clone button.
2. Open the project in Xcode by selecting the Lendivine.xcodeproj project file.
3. To build the application select the Lendivine scheme and then select Product > Run (alternatively select the Command + R keys).
4. The application can be built and run on either an iOS simulator target or an iPhone device running iOS 8.4 or later.
5. Credentials for the OAuth exchange are baked into the app. (See Constants.swift in the OAuth folder.) 


### Run Lendivine

This section describes how an end user can find and fund loans using the Lendivine application:

#### 1. Signup

A user must sign in with a Kiva.org account to access many features in the application. Access to signup and login are provided directly in the Lendivine app which implement the OAuth 1.0a authorization flow.

To Signup:

1. First, select the Login to Kiva.org button on the Login screen. 
2. The Kiva.org Signup page is presented. Enter the information you wish to use for your new Kiva account: first, last name, email and password, select the privacy policy / terms of use checkbox, and then select the Register button.
3. Kiva displays the "Authorize 3rd Party Application: Lendivine is requesting permission to access your Kiva account"
Scroll to the bottom of the page and select the "Allow" button.
Select "Open" in the "Open in Lendivine?" Alert.
You are now logged in and should see a list of current loans.

#### 2. Login

On subsequent sessions, select the Login button on the Login screen.
Select "Open" in the "Open in Lendivine?" Alert.
You are now logged in and should see a list of current loans.

#### 3. Loans

Upon completing login the application will display the loans screen. The app will query the Kiva REST API for the 20 most recent loans and display them in a table view. The user can access the following features in this screen:

* The user can select the shopping cart button in a table view cell to add that cell's loan to the cart. A heartbeat and bezier curve animation as well as a donation icon indicate the addition of the selected loan to the cart.
* There are three ways to search for additional loans:

  1. A search for additional loans can be made by selecting the '+' bar button item in the navigation bar at the top of the screen. If additional loans are found they are added to the table view's list.
  2. Pull to refresh:  Pull down on the table view to conveniently search for additional loans. (A refresh item is also available in the tab bar to provide access to the same functionality.)
  3. Select the "See More Loans..." button at the bottom of the table view.

* Loans can also be viewed geographically. Selecting the Map bar button item (rightmost bar button item) presents loans represented by pins on a map. (See the Map View below for more details.) This ability to switch between the map and list views of loans is available from several screens in the app that present loans.
* Select a loan to display details of the loan.
* Select the Map item in the navigation bar to see the loans displayed on a map.
* Select the Trash item to remove all loans from the list.

#### 4. Countries

Select the Countries tab to view a list of countries queried from the RESTCountries REST API. A custom cell displays information for each country including an image of the flag, and the population. 

* Select a country to display a list of recent loans requested by entreprenuers in that country. (See the Country Loans screen below for more details.)
* Select the globe in the search bar to search for loans by country by interacting with a map. (See the Map Search screen below.)

##### Search Bar

Because the list of countries is large the user can enter a string of characters in the search bar at the top of the screen. The characters are used to filter the list of countries displayed in the table view. For example type "nep" in the search bar to filter the list of countries to a single entry: "Nepal". Clear the selection to redisplay all 200 or so countries. 

##### Gini coefficient

Income inequality is a hot topic in the United States. I wanted to give users an opportunity to use this information to determine where they make loans. Each cell in this view displays a country's gini coefficient, which is a measure of income inequality. 0 represents complete equality while 100 represents maximum inequality.

#### 5. Cart

The Cart screen displays a list of loans that have been added to the cart. The following features are available in the Cart screen:

* Select the Cart icon in an individual cell to change the donation amount for the associated loan.
* Select the checkout button at the bottom of the table view (or the checkout item in the navigation bar) to send all loans in the cart to Kiva.org. When the checkout button is selected the user is transferred along with the items in the cart to the Kiva.org site to complete the checkout.
* Select a loan to display details of the loan in the Loan Detail View (see below).
* Select the Map button in the navigation bar to see the loans displayed on a map (see the Map View below).
* Swipe left on a cell to remove the corresponding item from the cart.
* Select the trash button (left bar button item) to remove all loans from the cart. 

#### 6. My Loans

The My Loans screen displays a list of the loans made with the currently logged in account. The following features are available in this screen:
* Select a loan to display details of the loan.
* Select the Map button in the navigation bar to see the loans displayed on a map.

#### 7. My Account

The My Account screen displays account details acquired from a request to the Kiva REST api. In this screen the user can see the account first and last name, email address used to login to Kiva.org, their LenderID, and the current account balance. The user's default donation preference is presented as a segmented control and persisted to user defaults.

I've layed out this screen to accomodate capturing or selecting an image to use as the account Image. (Unfortunately Kiva's REST API does not currently support acquiring or updating the account image so I am presently unable to integrate this feature with the account on Kiva.org.)

Account information acquired from kiva.org through the REST API is created/updated as a KivaAccount object in core data, and the UI is updated with any new data. The account image is stored on the local disk and named based upon the unique loanId (meaning only the loanId is stored in core data).

#### 8. Map View

All of the main screens in the app that display a list of loans to the user contain a bar button item that presents a map view of the loans. Each loan is represented by a pin on the map. The map is centered on a specific loan, or group of loans from a particular country. In this screen the following features are available: 
* Select a pin to display a callout displaying information about the loan.
* Select the right callout to display the Loan Detail screen for that loan.
* Select the Checkout button to send the cart to Kiva.org to complete checkout (This feature is only available when the map screen is displayed from the Cart screen).

#### 9. Loan Detail View
This view displays details about a specific loan.

* Select the thumbnail to display a larger version of the image in a popoverPresentationController.
* Select the Add to Cart button to add the loan to the cart. (This feature is not available when the Loan Detail screen is presented from the MyLoans screen.)
* See loan details like a thumbnail image of the requester of the loan, status of the loan, the sector, a description of the purpose of the loan, and the amount loaned to date.
* An MKMapView displays a pin identifying the location of the loan requester.
* Select the pin to see the city where the requester is located.
* The requester's country and flag are displayed at the top of the map.

#### 10. Country Loans View

The Country Loans view displays a list of the most recent loan requests posted in a single country.

* Select a Loan to see details of the loan. 
* Select the Map right bar button item to switch to a map view of the loans.
* Select the Cart button in a particular table view cell to add the loan to the cart.
* Select the Back bar button item to navigate back to the Countries screen.

#### 10. Map Search

The Map Search screen displays an MKMapView. Tap to select a country on the map. The app queries the Kiva API for loans in the selected country and displays them in the Country Loans View.


### Technical highlights

* Uses two REST apis: Kiva.org and RESTCountries.
* Core data to persist models.
* Implements OAuth 1.0a protocol to authenticate with the kiva.org service.
* Deep linking to redirect the user to the Lendivine app following login.
* UISearchController in Countries view controller enables search of view controller with a lot of data.
* MKMapView with annotations displaying a loan specific data including an image in the annotation callout.
* Custom animation when loan is added to the cart in the Loans view controller.
* Persists model data, particularly a user's CartItems. 
* Persists and refreshes Countries in core data to show how initialization performance can be enhanced while ensuring data is synced from the service. (We expect such an event to be infrequent in the real world, but here we are interested in the pattern which can be applied to other types of data that might update server side more frequently.  In our case if a new country is created, or another is dissolved, it will be automatically updated in core data by this code.)
* Implemented my own disk and memory cache of web image download to enhance performance.
* Implemented NSURLConnection based networking.
* Abstracted both REST APIs and the networking layer in separate classes following the separation of concerns design pattern.
* MVC design pattern.
* Swift exception handling.
* Popover controller

### References
* Kiva: The [Kiva.org REST API](https://build.kiva.org/api), and the [Kiva Developer Guide](http://build.kiva.org/)
* RESTCountries: The [RESTCountries API](https://restcountries.eu/)
* OAuthSwift: https://github.com/OAuthSwift/OAuthSwift

### Acknowledgements
* Icons 8: https://icons8.com
* The Noun Project: https://thenounproject.com

### License
Please see the license file for details about the license. This software is provided as is with no warranty.
