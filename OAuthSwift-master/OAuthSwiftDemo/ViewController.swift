    //
//  ViewController.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/21/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var kivaAPI: KivaAPI?
    
    var services = ["Kiva", "Twitter", "Flickr", "Github", "Instagram", "Foursquare", "Fitbit", "Withings", "Linkedin", "Linkedin2", "Dropbox", "Dribbble", "Salesforce", "BitBucket", "GoogleDrive", "Smugmug", "Intuit", "Zaim", "Tumblr", "Slack", "Uber"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "OAuth"
        let tableView: UITableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        // Add a checkout button on the right of the navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Checkout", style: .Plain, target: self, action: "checkout")
        // disable the checkout button
        self.navigationItem.rightBarButtonItem!.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func doOAuthTwitter(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Twitter["consumerKey"]!,
            consumerSecret: Twitter["consumerSecret"]!,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        //oauthswift.authorize_url_handler = WebViewController()
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/twitter")!, success: {
            credential, response in
            self.showAlertView("Twitter", message: "auth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            let parameters =  Dictionary<String, AnyObject>()
            oauthswift.client.get("https://api.twitter.com/1.1/statuses/mentions_timeline.json", parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    print(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    print(error)
                })
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
            }
        )
    }
    
    func doOAuthKiva(){
//        let mySing = MySingleton.sharedInstance
//        print("timestampInHeader = \(mySing.timeStampInHeader), but I'm changing it to true.")
//        mySing.timeStampInHeader = true
//        print("timestampInHeader = \(mySing.timeStampInHeader) in ViewController.swift")
        
        let oauthswift = OAuth1Swift(
            consumerKey:    Kiva["consumerKey"]!,
            consumerSecret: Kiva["consumerSecret"]!,
            requestTokenUrl: "https://api.kivaws.org/oauth/request_token",
            authorizeUrl:    "https://www.kiva.org/oauth/authorize",
            accessTokenUrl:  "https://api.kivaws.org/oauth/access_token"
            )
            // "https://build.kiva.org/apps#create", "oauth-swift://oauth-callback/kiva", "oob", or "https://github.com/jdbateman" for callback string
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/kiva")!, success: {
            credential, response in
            
            print("bravo. Now make a call to the Kiva api")
            
            print("oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
            self.showAlertView("Kiva", message: "oauth_token:\(credential.oauth_token)\n\noauth_token_secret:\(credential.oauth_token_secret)")
            
            // TODO: securely store the access credentials
            
            // TODO: make a call to a Kiva API using the access credentials.
            
            print("")
            print("****************************************************************************")
            print("Step 4: Make Kiva API request with Access Token")
            //print("")
            
            let url :String = "https://api.kivaws.org/v1/my/account.json"
            
            // set the oauth_token parameter. remove any existing URL encoding (% escaped characters)
            var parameters =  Dictionary<String, AnyObject>()
            var oauthToken = credential.oauth_token
            oauthToken = oauthToken.stringByRemovingPercentEncoding!
            parameters = [
                "oauth_token"    : oauthToken
            ]
            
            oauthswift.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    print("Kiva API request succeeded.")
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    print(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    print("Kiva API request failed.")
                    print(error)
            })
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
            }
        )

    }

    func doOAuthFlickr(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Flickr["consumerKey"]!,
            consumerSecret: Flickr["consumerSecret"]!,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/flickr")!, success: {
            credential, response in
            self.showAlertView("Flickr", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            let url :String = "https://api.flickr.com/services/rest/"
            let parameters :Dictionary = [
                "method"         : "flickr.photos.search",
                "api_key"        : Flickr["consumerKey"]!,
                "user_id"        : "128483205@N08",
                "format"         : "json",
                "nojsoncallback" : "1",
                "extras"         : "url_q,url_z"
            ]
            oauthswift.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    print(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    print(error)
            })
        }, failure: {(error:NSError!) -> Void in
            print(error.localizedDescription)
        })
    }

    func doOAuthGithub(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Github["consumerKey"]!,
            consumerSecret: Github["consumerSecret"]!,
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/github")!, scope: "user,repo", state: state, success: {
            credential, response, parameters in
            self.showAlertView("Github", message: "oauth_token:\(credential.oauth_token)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
            })
    }
    func doOAuthSalesforce(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Salesforce["consumerKey"]!,
            consumerSecret: Salesforce["consumerSecret"]!,
            authorizeUrl:   "https://login.salesforce.com/services/oauth2/authorize",
            accessTokenUrl: "https://login.salesforce.com/services/oauth2/token",
            responseType:   "code"
        )
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/salesforce")!, scope: "full", state: state, success: {
            credential, response, parameters in
            self.showAlertView("Salesforce", message: "oauth_token:\(credential.oauth_token)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }

    func doOAuthInstagram(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Instagram["consumerKey"]!,
            consumerSecret: Instagram["consumerSecret"]!,
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )

        let state: String = generateStateWithLength(20) as String
        oauthswift.authorize_url_handler = WebViewController()
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/instagram")!, scope: "likes+comments", state:state, success: {
            credential, response, parameters in
            self.showAlertView("Instagram", message: "oauth_token:\(credential.oauth_token)")
            let url :String = "https://api.instagram.com/v1/users/1574083/?access_token=\(credential.oauth_token)"
            let parameters :Dictionary = Dictionary<String, AnyObject>()
            oauthswift.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    print(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    print(error)
            })
        }, failure: {(error:NSError!) -> Void in
            print(error.localizedDescription)
        })
    }

    func doOAuthFoursquare(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Foursquare["consumerKey"]!,
            consumerSecret: Foursquare["consumerSecret"]!,
            authorizeUrl:   "https://foursquare.com/oauth2/authorize",
            responseType:   "token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/foursquare")!, scope: "", state: "", success: {
            credential, response, parameters in
            self.showAlertView("Foursquare", message: "oauth_token:\(credential.oauth_token)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
            })
    }
    func doOAuthFitbit(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Fitbit["consumerKey"]!,
            consumerSecret: Fitbit["consumerSecret"]!,
            requestTokenUrl: "https://api.fitbit.com/oauth/request_token",
            authorizeUrl:    "https://www.fitbit.com/oauth/authorize?display=touch",
            accessTokenUrl:  "https://api.fitbit.com/oauth/access_token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/fitbit")!, success: {
            credential, response in
            self.showAlertView("Fitbit", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }

    func doOAuthWithings(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Withings["consumerKey"]!,
            consumerSecret: Withings["consumerSecret"]!,
            requestTokenUrl: "https://oauth.withings.com/account/request_token",
            authorizeUrl:    "https://oauth.withings.com/account/authorize",
            accessTokenUrl:  "https://oauth.withings.com/account/access_token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/withings")!, success: {
            credential, response in
            self.showAlertView("Withings", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }

    func doOAuthLinkedin(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Linkedin["consumerKey"]!,
            consumerSecret: Linkedin["consumerSecret"]!,
            requestTokenUrl: "https://api.linkedin.com/uas/oauth/requestToken",
            authorizeUrl:    "https://api.linkedin.com/uas/oauth/authenticate",
            accessTokenUrl:  "https://api.linkedin.com/uas/oauth/accessToken"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/linkedin")!, success: {
            credential, response in
            self.showAlertView("Linkedin", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            let parameters =  Dictionary<String, AnyObject>()
            oauthswift.client.get("https://api.linkedin.com/v1/people/~", parameters: parameters,
                    success: {
                        data, response in
                        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                        print(dataString)
                    }, failure: {(error:NSError!) -> Void in
                print(error)
            })
        }, failure: {(error:NSError!) -> Void in
            print(error.localizedDescription)
        })
    }

    func doOAuthLinkedin2(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Linkedin2["consumerKey"]!,
            consumerSecret: Linkedin2["consumerSecret"]!,
            authorizeUrl:   "https://www.linkedin.com/uas/oauth2/authorization",
            accessTokenUrl: "https://www.linkedin.com/uas/oauth2/accessToken",
            responseType:   "code"
        )
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: "http://oauthswift.herokuapp.com/callback/linkedin2")!, scope: "r_fullprofile", state: state, success: {
            credential, response, parameters in
            self.showAlertView("Linkedin2", message: "oauth_token:\(credential.oauth_token)")
            let parameters =  Dictionary<String, AnyObject>()
            oauthswift.client.get("https://api.linkedin.com/v1/people/~?format=json", parameters: parameters,
                success: {
                    data, response in
                    let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print(dataString)
                }, failure: {(error:NSError!) -> Void in
                    print(error)
            })
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }

    func doOAuthSmugmug(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Smugmug["consumerKey"]!,
            consumerSecret: Smugmug["consumerSecret"]!,
            requestTokenUrl: "http://api.smugmug.com/services/oauth/getRequestToken.mg",
            authorizeUrl:    "http://api.smugmug.com/services/oauth/authorize.mg",
            accessTokenUrl:  "http://api.smugmug.com/services/oauth/getAccessToken.mg"
        )
        oauthswift.allowMissingOauthVerifier = true
        // NOTE: Smugmug's callback URL is configured on their site and the one passed in is ignored.
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/smugmug")!, success: {
            credential, response in
            self.showAlertView("Smugmug", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
        }, failure: {(error:NSError!) -> Void in
            print(error.localizedDescription)
        })
    }

    func doOAuthDropbox(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Dropbox["consumerKey"]!,
            consumerSecret: Dropbox["consumerSecret"]!,
            authorizeUrl:   "https://www.dropbox.com/1/oauth2/authorize",
            accessTokenUrl: "https://api.dropbox.com/1/oauth2/token",
            responseType:   "token"
        )
        oauthswift.authorize_url_handler = WebViewController()
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/dropbox")!, scope: "", state: "", success: {
            credential, response, parameters in
            self.showAlertView("Dropbox", message: "oauth_token:\(credential.oauth_token)")
            // Get Dropbox Account Info
            let parameters =  Dictionary<String, AnyObject>()
            oauthswift.client.get("https://api.dropbox.com/1/account/info?access_token=\(credential.oauth_token)", parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    print(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    print(error)
                })
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }

    func doOAuthDribbble(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Dribbble["consumerKey"]!,
            consumerSecret: Dribbble["consumerSecret"]!,
            authorizeUrl:   "https://dribbble.com/oauth/authorize",
            accessTokenUrl: "https://dribbble.com/oauth/token",
            responseType:   "code"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/dribbble")!, scope: "", state: "", success: {
            credential, response, parameters in
            self.showAlertView("Dribbble", message: "oauth_token:\(credential.oauth_token)")
            // Get User
            let parameters =  Dictionary<String, AnyObject>()
            oauthswift.client.get("https://api.dribbble.com/v1/user?access_token=\(credential.oauth_token)", parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    print(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    print(error)
                })
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }

	func doOAuthBitBucket(){
		let oauthswift = OAuth1Swift(
			consumerKey:    BitBucket["consumerKey"]!,
			consumerSecret: BitBucket["consumerSecret"]!,
			requestTokenUrl: "https://bitbucket.org/api/1.0/oauth/request_token",
			authorizeUrl:    "https://bitbucket.org/api/1.0/oauth/authenticate",
			accessTokenUrl:  "https://bitbucket.org/api/1.0/oauth/access_token"
		)
		oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/bitbucket")!, success: {
			credential, response in
			self.showAlertView("BitBucket", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
			let parameters =  Dictionary<String, AnyObject>()
			oauthswift.client.get("https://bitbucket.org/api/1.0/user", parameters: parameters,
				success: {
					data, response in
					let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
					print(dataString)
				}, failure: {(error:NSError!) -> Void in
					print(error)
			})
			}, failure: {(error:NSError!) -> Void in
				print(error.localizedDescription)
		})
	}
    func doOAuthGoogle(){
        let oauthswift = OAuth2Swift(
            consumerKey:    GoogleDrive["consumerKey"]!,
            consumerSecret: GoogleDrive["consumerSecret"]!,
            authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        // For googgle the redirect_uri should match your this syntax: your.bundle.id:/oauth2Callback
        // in plist define a url schem with: your.bundle.id:
        oauthswift.authorizeWithCallbackURL( NSURL(string: "https://oauthswift.herokuapp.com/callback/google")!, scope: "https://www.googleapis.com/auth/drive", state: "", success: {
            credential, response, parameters in
            self.showAlertView("Google", message: "oauth_token:\(credential.oauth_token)")
            let parameters =  Dictionary<String, AnyObject>()
            // Multi-part upload
            oauthswift.client.postImage("https://www.googleapis.com/upload/drive/v2/files", parameters: parameters, image: self.snapshot(),
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    print("SUCCESS: \(jsonDict)")
                }, failure: {(error:NSError!) -> Void in
                    print(error)
            })
            }, failure: {(error:NSError!) -> Void in
                print("ERROR: \(error.localizedDescription)")
        })
    }

    func doOAuthIntuit(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Intuit["consumerKey"]!,
            consumerSecret: Intuit["consumerSecret"]!,
            requestTokenUrl: "https://oauth.intuit.com/oauth/v1/get_request_token",
            authorizeUrl:    "https://appcenter.intuit.com/Connect/Begin",
            accessTokenUrl:  "https://oauth.intuit.com/oauth/v1/get_access_token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/intuit")!, success: {
            credential, response in
            self.showAlertView("Intuit", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }
    func doOAuthZaim(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Zaim["consumerKey"]!,
            consumerSecret: Zaim["consumerSecret"]!,
            requestTokenUrl: "https://api.zaim.net/v2/auth/request",
            authorizeUrl:    "https://auth.zaim.net/users/auth",
            accessTokenUrl:  "https://api.zaim.net/v2/auth/access"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/zaim")!, success: {
            credential, response in
            self.showAlertView("Zaim", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }
    func doOAuthTumblr(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Tumblr["consumerKey"]!,
            consumerSecret: Tumblr["consumerSecret"]!,
            requestTokenUrl: "http://www.tumblr.com/oauth/request_token",
            authorizeUrl:    "http://www.tumblr.com/oauth/authorize",
            accessTokenUrl:  "http://www.tumblr.com/oauth/access_token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/tumblr")!, success: {
            credential, response in
            self.showAlertView("Tumblr", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }
    func doOAuthSlack(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Slack["consumerKey"]!,
            consumerSecret: Slack["consumerSecret"]!,
            authorizeUrl:   "https://slack.com/oauth/authorize",
            accessTokenUrl: "https://slack.com/api/oauth.access",
            responseType:   "code"
        )
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/slack")!, scope: "", state: state, success: {
            credential, response, parameters in
            self.showAlertView("Slack", message: "oauth_token:\(credential.oauth_token)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription, terminator: "")
        })
    }

    func doOAuthUber(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Uber["consumerKey"]!,
            consumerSecret: Uber["consumerSecret"]!,
            authorizeUrl:   "https://login.uber.com/oauth/authorize",
            accessTokenUrl: "https://login.uber.com/oauth/token",
            responseType:   "code",
            contentType:    "multipart/form-data"
        )
        let state: String = generateStateWithLength(20) as String
        let redirectURL = "https://oauthswift.herokuapp.com/callback/uber".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        oauthswift.authorizeWithCallbackURL( NSURL(string: redirectURL!)!, scope: "profile", state: state, success: {
            credential, response, parameters in
            self.showAlertView("Uber", message: "oauth_token:\(credential.oauth_token)")
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription, terminator: "")
        })
    }

    func snapshot() -> NSData {
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let fullScreenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(fullScreenshot, nil, nil, nil)
        return  UIImageJPEGRepresentation(fullScreenshot, 0.5)!
    }

    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return services.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = services[indexPath.row]
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let service: String = services[indexPath.row]
        switch service {
            case "Twitter":
                doOAuthTwitter()
            
            case "Kiva":
                let kivaOAuth = KivaOAuth()
                kivaOAuth.doOAuthKiva() {success, error, kivaAPI in
                    if success {
                        self.kivaAPI = kivaOAuth.kivaAPI
                        
                        // enable the checkout button
                        self.navigationItem.rightBarButtonItem!.enabled = true
                        
                        // test functions in the Kiva API
                        kivaOAuth.testKivaAPI()
                        
                    } else {
                        print("kivaOAuth failed. Unable to acquire kivaAPI handle.")
                    }
                }
            
                //doOAuthKiva()
            
            case "Flickr":
                doOAuthFlickr()
            case "Github":
                doOAuthGithub()
            case "Instagram":
                doOAuthInstagram()
            case "Foursquare":
                doOAuthFoursquare()
            case "Fitbit":
                doOAuthFitbit()
            case "Withings":
                doOAuthWithings()
            case "Linkedin":
                doOAuthLinkedin()
            case "Linkedin2":
                doOAuthLinkedin2()
            case "Dropbox":
                doOAuthDropbox()
            case "Dribbble":
                doOAuthDribbble()
            case "Salesforce":
                doOAuthSalesforce()
            case "BitBucket":
                doOAuthBitBucket()
            case "GoogleDrive":
                doOAuthGoogle()
            case "Smugmug":
                doOAuthSmugmug()
            case "Intuit":
                doOAuthIntuit()
            case "Zaim":
                doOAuthZaim()
            case "Tumblr":
                doOAuthTumblr()
            case "Slack":
                doOAuthSlack()
            case "Uber":
                doOAuthUber()
            default:
                print("default (check ViewController tableView)")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    func checkout() {
        print("checkout called")
        
        let numberOfLoans = Int(arc4random() % 12)
        putLoansInCart(numberOfLoans) {success, error in
            if success {
                self.showEmbeddedBrowser()
            } else {
                print("failed to put any loans in the cart")
            }
        }
        
        //    TODO - this is a data class. Need to move this logic to a view class and create a view controller for the web view. Look at code in OnTheMap.
        //
        //    /* Create a UIWebView the size of the screen and set it's delegate to this view controller. */
        //    func showWebView(request: NSURLRequest?) {
        //        let webView:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        //        webView.delegate = self
        //        if let url = url {
        //            webView.loadRequest(request)
        //            self.view.addSubview(webView)
        //        }
        //    }
        
    }
    
    // Add some randomly selected loans to the cart.
    func putLoansInCart(numberOfLoansToAdd: Int, completionHandler: (success: Bool, error: NSError?) -> Void) {
        if let kivaAPI = self.kivaAPI {
            self.findLoans(kivaAPI) { success, error, loanResults in
                if success {
                    if var loans = loanResults {
                        
                        // just keep the first 5 loans
                        loans.removeRange(numberOfLoansToAdd..<loans.count)
                        
                        for loan in loans {
                            // put the  loan into the cart
                            let loanId = loan.id
                            let amount = ( ( Int(arc4random() % 100) / 5 ) * 5) + 5
                            print("amount of loan = \(amount)")
                            kivaAPI.KivaAddItemToCart(loan.id, amount: amount)
                            
                            print("cart contains loanId: \(loanId) in amount: \(amount)")
                        }

                        completionHandler(success: true, error: nil)
                    }
                } else {
                    print("failed")
                    completionHandler(success: false, error: error)
                }
            }
        } else {
            print("no kivaAPI")
            completionHandler(success: false, error: nil)
        }
    }
    
    // helper function that searches for loans
    func findLoans(kivaAPI: KivaAPI, completionHandler: (success: Bool, error: NSError?, loans: [KivaLoan]?) -> Void) {
        
        let regions = "ca,sa,af,as,me,ee,we,an,oc"
        let countries = "TD,TG,TH,TJ,TL,TR,TZ"
        kivaAPI.kivaSearchLoans(queryMatch: "family", status: KivaAPI.LoanStatus.fundraising.rawValue, gender: nil, regions: regions, countries: nil, sector: KivaAPI.LoanSector.Agriculture, borrowerType: KivaAPI.LoanBorrowerType.individuals.rawValue, maxPartnerRiskRating: KivaAPI.PartnerRiskRatingMaximum.medLow, maxPartnerDelinquency: KivaAPI.PartnerDelinquencyMaximum.medium, maxPartnerDefaultRate: KivaAPI.PartnerDefaultRateMaximum.medium, includeNonRatedPartners: true, includedPartnersWithCurrencyRisk: true, page: 1, perPage: 20, sortBy: KivaAPI.LoanSortBy.popularity.rawValue) { success, error, loanResults in
            
            if success {
                // print("search loans results: \(loanResults)")
                completionHandler(success: success, error: error, loans: loanResults)
            } else {
                // print("kivaSearchLoans failed")
                completionHandler(success: success, error: error, loans: nil)
            }
        }
    }
    
    /* Display url in an embeded webkit browser. */
    func showEmbeddedBrowser() {
        var controller = CartViewController()
        //        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        //        var controller = storyboard.instantiateViewControllerWithIdentifier("WebSearchStoryboardID") as! WebSearchViewController
        //controller.initialURL = url
        if let kivaAPI = self.kivaAPI {
            controller.request = self.kivaAPI!.getKivaCartRequest()  // KivaCheckout()
        }
        //controller.webViewDelegate = self
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
//    func createCartViewController() {
//        let controller = WebViewController() //CartViewController()
//        controller.view = UIView(frame: CGRect(x:0, y:0, width: 450, height: 500)) // needed if no nib or not loaded from storyboard
//        controller.viewDidLoad()
//        
//        //controller.initialURL = url
////        controller.request = self.kivaAPI.KivaCheckout()
////        controller.webViewDelegate = self
//        
//        self.addChildViewController(controller)
//    }
}
