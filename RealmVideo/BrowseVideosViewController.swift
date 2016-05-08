//
//  BrowseVideosViewController.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/6/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit


class BrowseVideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var welcome: WelcomeViewController?
    var videos = [Video]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            videos = try RealmParser().videos
        } catch {
            tableView.hidden = true
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath)
        let video = videos[indexPath.row]
        cell.textLabel?.text = video.title
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(15)
        cell.detailTextLabel?.text = video.url
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = videos[indexPath.row].url
        dismissViewControllerAnimated(true) { 
            self.welcome?.textField.text = url
            self.welcome?.performSegueWithIdentifier("RealmVideo", sender: nil)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
