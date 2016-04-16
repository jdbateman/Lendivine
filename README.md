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

The project is written and compiled in Swift 2.2 for an iOS base version of 8.4.

### Build Lendivine

To build the Lendivine project you will need Xcode 7.0 or later. The application deployment target is 8.4. Follow these steps to get the project running on your machine:

1. Clone the project to your local machine from Github using the clone button.
2. Open the project in Xcode by selecting the Lendivine.xcodeproj project file.
3. To build the application select the Lendivine scheme and then select Product > Run (alternatively select the Command + R keys).
4. The application can be built and run on either an iOS simulator target or an iPhone device running iOS 8.4 or later.


### Run Lendivine

This section describes how an end user can find and fund loans using the Lendivine application:

#### 1. Signup

First, signup for a Kiva.org account on www.kiva.org using a web browser on any device. Conveniently, signup can be accessed right in the app by selecting signup at the bottom of the Login screen. This will display the Kiva.org signup interface in an embedded browser in the Lendivine application.

#### 2. Login

After signing up return to the Login screen and select Login to authenticate with the Kiva service via the OAuth protocol. As part of the OAuth process the Kiva.org service may prompt the user to provide their username and password. Kiva will use these credentials to authenticate the user with the Kiva service. Once the credentials are authenticated the service will prompt the user if they want to "Open in Lendivine". If the user responds Yes Kiva redirects the user to the Lendivine application.

#### 3. Loans

Upon completing login the application will display the screen associated with the first tab. This is the loans screen. The app will query the Kiva REST API for the 20 most recent loans and display them in a table view. The user can access the following features in this screen:

* The user can select the shopping cart button in a cell to add that cell's loan to the cart. A heartbeat and bezier curve animation as well as a donation icon indicate the addition of the selected loan to the cart.
* A search for additional loans can be made by selecting the refresh bar button item in the navigation bar at the top of the screen. If additional loans are found they are appendec to the table view's list.
* Pull to refresh:  Pull down on the table view to conveniently search for additional loans. (A refresh item is also available in the tab bar to provide access to the same functionality.)
* Select a loan to display details of the loan.
* Select the Map item in the navigation bar to see the loans displayed on a map.
* Select the Trash item to remove all loans from the list.
* Select the Play icon to re-authenticate with Kiva.org. (This feature is exposed as a convenience to developers. It would not be exposed to end users in a version of the application deployed on the App store.)

#### 4. Countries

Select the Countries tab to view a list of countries queried from the RESTCountries REST API. A custom cell displays information for each country including an image of the flag, and the population. Select a country to display a list of recent loans requested by entreprenuers in that country. 

##### Search Bar

Because the list of countries is large the user can enter a string of characters in the search bar at the top of the screen. The characters are used to filter the list of countries displayed in the table view. For example type "nep" in the search bar to filter the list of countries to a single entry: "Nepal". Clear the selection to redisplay all 200 or so countries. 

##### Gini coefficient

Income inequality is a hot topic in the United States. I wanted to give users an opportunity to use this information to determine where they make loans. Each cell in this view displays a country's gini coefficient, which is a measure of income inequality. 0 represents complete equality while 100 represents maximum inequality.

#### 5. Cart

The Cart screen displays a list of loans that have been added to the cart. The following features are available in the Cart screen:

* Select the Cart icon in an individual cell to change the donation amount for the loan displayed in that cell.
* Select the checkout button at the bottom of the table view (or the checkout item in the navigation bar) to send all loans in the cart to Kiva.org. When the checkout button is selected the user is transferred along with the items in the cart to the Kiva.org site to complete the checkout.
* Select a loan to display details of the loan.
* Select the Map button in the navigation bar to see the loans displayed on a map.
* Swipe left on a cell to remove the corresponding item from the cart.
* Select the trash button in the navigation bar at the top of the screen to remove all loans from the cart. 

#### 6. My Loans

The My Loans screen displays a list of the loans previously made under the currently logged in account. The following features are available in this screen:
* Select a loan to display details of the loan.
* Select the Map button in the navigation bar to see the loans displayed on a map.

#### 7. My Account

The My Account screen displays account details acquired from a request to the Kiva REST api. In this screen the user can see the email address used to login to Kiva.org, their LenderID, and the current account balance.

I've layed out this screen to accomodate capturing or selecting an image to use as the account Image. (Unfortunately Kiva's REST API does not currently support acquiring or updating the account image so I am presently unable to integrate this feature with the account on Kiva.org.)

Map view
* When displayed from the My Loans screen the user can select the Add to Cart button in the Loan Details screen to make an additional contribution to the same loan. The loan will be re-added to the cart if it is not presently in the cart.


### Technical highlights

* Uses two REST apis: Kiva.org and RESTCountries.
* Implements OAuth 1.x to authenticate with the kiva.org service.
* Deep linking to redirect the user to the Lendivine app following login.
* UISearchController in Countries view controller enables search of view controller with a lot of data.
* Swift exception handling.
* MKMapView with annotations displaying a loan image in the annotation callout.
* Custom animation when loan is selected in the Loans view controller.
* Persists model data, particularly a user's CartItems. 
* Persists and refreshes Countries in core data to show how initialization performance can be enhanced while ensuring data is synced from the service. (We expect such an event to be infrequent in the real world, but here we are interested in the pattern which can be applied to other types of data that might update server side more frequently.  In our case if a new country is created, or another is dissolved, it will be automatically updated in core data by this code.)
* Implemented my own disk and memory cache of web image download to enhance performance.
* Implemented NSURLConnection based networking.
* Abstracted both REST APIs and the networking layer in separate classes following the separation of concerns design pattern.
* MVC design pattern.

### References
* Kiva references: The [Kiva.org REST API](https://build.kiva.org/api), and the [Kiva Developer Guide](http://build.kiva.org/)
* RESTCountries reference: The [RESTCountries API](https://restcountries.eu/)

### Acknowledgements
* Icons 8

### License
Please see the license file for details about the license. This software is provided as is with no warranty.
