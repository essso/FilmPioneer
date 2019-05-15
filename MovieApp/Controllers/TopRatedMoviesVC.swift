//
//  TopRatedMoviesVC.swift
//  MovieApp
//
//  Created by Esraa Mohamed Ragab on 5/15/19.
//

import UIKit

class TopRatedMoviesVC: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - outlets
    @IBOutlet weak var topRatedMoviesCollectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    
    // MARK: - variables
    var pageNum = 1
    var totalPages = 1
    var isWating = false
    var results : [Results] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topRatedMoviesCollectionView.register(UINib(nibName: "FullRawCell", bundle: nil), forCellWithReuseIdentifier: "FullRawCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageNum = 1
        totalPages = 1
        results = []
        topRatedMoviesCollectionView.reloadData()
        callApiGetMovies()
    }
    
    // Buttons Actions
    
    @IBAction func reloadData(_ sender: Any) {
        callApiGetMovies()
    }
    
    // MARK: - collection View Delegate FlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 110)
    }
    
    // MARK: - collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        callApiGetMovies()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == results.count - 2 && !isWating {
            isWating = true
            pageNum += 1
            self.getMoreMovies()
        }
    }
    
    private func getMoreMovies() {
        callApiGetMovies()
    }
    
    // MARK: - collection View DataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullRawCell", for: indexPath) as! fullRawCell
        let item = results[indexPath.row]
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.layer.shadowRadius = 8
        cell.layer.shadowOpacity = 0.6
        cell.layer.shadowColor = (UIColor().black).cgColor
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath

        cell.displayData(title: item.title, average: "\(item.voteAverage!)", date: item.releaseDate, posterImage: item.posterPath)
        return cell
    }
    
    func callApiGetMovies(){
        self.reloadButton.isHidden = true
        if pageNum > totalPages {
            return
        } else {
            loadingIndicator.startAnimating()
        }
        if NetworkManager.sharedInstance.isConnected() {
            NetworkManager.sharedInstance.serverRequests(url: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(Constants.api.api_key.rawValue)&language=en-US&page=\(pageNum)", success: { (res) in
                let moviesDic = Movies.init(fromDictionary: res)
                self.results.append(contentsOf: moviesDic.results)
                self.totalPages = moviesDic.totalPages
                self.isWating = false
                self.topRatedMoviesCollectionView.reloadData()
                self.loadingIndicator.stopAnimating()
                self.reloadButton.isHidden = true
            }) { (error) in
                self.loadingIndicator.stopAnimating()
                
                self.reloadButton.isHidden = self.pageNum == 1 ? false : true
                self.Alert(title: "Error!", message: error["status_message"] as? String ?? "Error", VC: self)
            }
        } else {
            reloadButton.isHidden = self.pageNum == 1 ? false : true
            self.pageNum == 1 ? Alert(title: "Error!", message: "Please Connect to the Internet..", VC: self): nil
            loadingIndicator.stopAnimating()
        }
    }
}
