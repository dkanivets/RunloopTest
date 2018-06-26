//
//  FeedsTableViewController.swift
//  RunloopTest
//
//  Created by Dmitry Kanivets on 26.06.18.
//  Copyright © 2018 Dmitry Kanivets. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class FeedsTableViewController: UITableViewController {
    var viewModel: FeedsViewModelProtocol = FeedsViewModel()
    var timer: Timer?
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()

        if let segmentedControl = self.navigationController!.navigationBar.topItem?.titleView as? UISegmentedControl {
            segmentedControl.reactive.mapControlEvents(.valueChanged, {$0.selectedSegmentIndex}).observeValues { [weak self] index in
                if let feedType = FeedType(rawValue: index) {
                    self?.viewModel.selectedFeedType = feedType
                    self?.update()
                }
            }
        }
        self.setupUI()
        self.update()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    fileprivate func setupUI() {
        tableView.tableFooterView = UIView(frame: .zero)
        activityIndicator.hidesWhenStopped = true
    }
    
    fileprivate func showIndicator() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.activityIndicator.isHidden = false
    }
    
    fileprivate func hideIndicator() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func update() {
        self.viewModel.updateItemsAction.apply(self.viewModel.selectedFeedType).on(
            starting: {
                self.showIndicator()
        },
            terminated: {
                self.hideIndicator()
        },
            value: { items in
                self.viewModel.items = items
                self.tableView.reloadData()
        }).start()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.viewModel.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedItemTableViewCell.indetifier) as! FeedItemTableViewCell
        cell.titleLabel.text = self.viewModel.items[indexPath.row].title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.viewModel.selectedFeed.value = self.viewModel.items[indexPath.row]
        self.performSegue(withIdentifier: "showDetail", sender: indexPath);
    }
    
    // MARK: - UIStoryboardSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FeedItemDetailViewController, let indexPath = sender as? IndexPath, (segue.identifier == "showDetail") {
            controller.feedItem = self.viewModel.items[indexPath.row]
        }
    }

}
