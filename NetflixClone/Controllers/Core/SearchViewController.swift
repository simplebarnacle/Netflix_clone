//
//  SearchViewController.swift
//  NetflixClone
//
//  Created by jayden on 2023/03/24.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var titles: [Title] = [Title]()
    
    private let discoverTable: UITableView = {
        
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: "TitleTableViewCell")
        return table
    }()
    
    private let searchController: UISearchController = {
       let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a Movie or Tv show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always

        view.backgroundColor = .systemBackground
        
        view.addSubview(discoverTable)
        
        discoverTable.delegate = self
        discoverTable.dataSource = self
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.tintColor = .label
        fetchDiscoverMovies()
        
        searchController.searchResultsUpdater = self
    }
    
    private func fetchDiscoverMovies() {
        APICaller.shared.getDiscoverMovies {[weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        discoverTable.frame = view.bounds
    }

}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell" , for: indexPath) as? TitleTableViewCell else { return UITableViewCell() }
        
        let title = titles[indexPath.row]
        cell.configure(with: TitleViewModel(titleName: title.original_title ?? "unknown title name", posterURL: title.poster_path ?? ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        
        guard let titleName = title.original_title ?? title.original_name else {
            return
        }
        APICaller.shared.getMovie(with: titleName) {[weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverView: title.overview ?? ""))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
                let resultController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        
        resultController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let titles):
                    resultController.titles = titles
                    resultController.searchResultsCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                    
                }
            }
        }
    }
    
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
