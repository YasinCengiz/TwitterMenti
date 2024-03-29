//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import CoreML
import SwifteriOS
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    
    let swifter = Swifter(consumerKey: "TWITTER_CONSUMER_KEY", consumerSecret: "SECRET_KEY")
    
    let sentimentClassifier = TwitterSentiment()

    // Number of tweets that will be analyzed
    let tweetCount = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    

    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
        
    }
    
    
    
    
    func fetchTweets() {
        
        if let searchText = textField.text {

        swifter.searchTweet(using: searchText,
                            lang: "en",
                            count: tweetCount,
                            tweetMode: .extended,
                            success: {(results, metadata) in
                                
                                //MARK: JSON PARSING
                        // GET THE GIVEN AMOUNT OF TWEET TEXTS AND ADD IT TO AN ARRAY
                                var tweets = [TwitterSentimentInput]()
                                
                                for i in 0 ..< self.tweetCount {
                                    if let tweet = results[i]["full_text"].string {
                                        let tweetClassification = TwitterSentimentInput(text: tweet)
                                        tweets.append(tweetClassification)
                                    }
                                    
                                }
                                
                                self.makePrediction(with: tweets)
                                
                                //MARK: API REQUEST ERROR
                                
                            }) { (error) in
                                print("Error with API request --> \(error)")
                            }
        
        }
        
    }
    
    
    
    func makePrediction(with tweets: [TwitterSentimentInput]) {
        
        do {
            
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions {
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
                
            }
            
            updateUI(with: sentimentScore)
            
        } catch {
            print("Error marking prediction \(error)")
        }
        
    }
    
    
    
    func updateUI(with sentimentScore: Int) {
        
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😆"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😁"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "🙁"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😠"
        } else {
            self.sentimentLabel.text = "😡"
        }
        
    }
    

    
    
    
    
}

