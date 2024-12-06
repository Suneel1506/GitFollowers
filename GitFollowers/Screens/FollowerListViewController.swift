
import UIKit

class FollowerListViewController: GFDataLoadingViewController {
    
    enum Section {
        case main
    }
    
    //MARK: - Properties
    
    var userName: String!
    var page = 1
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var hasMoreFollowers = true
    var isSearching = false
    var isLoadingMoreFollowers = false
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    //MARK: - Initializers
    
    init(userName: String) {
        super.init(nibName: nil, bundle: nil)
        self.userName = userName
        title = userName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureSearchController()
        configureCollectionView()
        getFollowers(userName: userName, page: page)
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Configure UI
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    //MARK: - API Calls
    
    func getFollowers(userName: String, page: Int) {
        showLoadingView()
        isLoadingMoreFollowers = true
        //        NetworkManager.shared.getFollowers(for: userName, page: page) { [weak self] result in
        //
        //            guard let self = self else { return }
        //            dismissLaoadingView()
        //
        //            switch result {
        //            case .success(let followers):
        //                self.updateUI(with: followers)
        //
        //            case .failure(let error):
        //                self.presentGFAlertOnMainThread(title: "Bad Request",
        //                                                message: error.rawValue,
        //                                                buttonTitle: "Ok")
        //            }
        //            self.isLoadingMoreFollowers = false
        //        }
        Task {
            do {
                let followers = try await NetworkManager.shared.getFollowers(for: userName, page: page)
                updateUI(with: followers)
                dismissLaoadingView()
            } catch {
                //handle errors
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Bad Request",
                                   message: gfError.rawValue,
                                   buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
                dismissLaoadingView()
            }
            
            //            guard let followers = try? await NetworkManager.shared.getFollowers(for: userName, page: page) else {
            //                presentDefaultError()
            //                return
            //            }
            //            updateUI(with: followers)
            //            dismissLaoadingView()
        }
    }
    
    //MARK: - Updates
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func updateUI(with followers: [Follower]) {
        if followers.count < 100 {
            self.hasMoreFollowers = false
        }
        self.followers.append(contentsOf: followers)
        
        if self.followers.isEmpty {
            let message = "This user doesn't have any followers yet. Go follow them 😀"
            DispatchQueue.main.async {
                self.showEmptyStateView(with: message, in: self.view)
            }
        }
        self.updateData(on: self.followers)
    }
    
    func addUserToFavourites(user: User) {
        let favourite = Follower(login: user.login,
                                 avatarUrl: user.avatarUrl)
        PersistenceManager.updateWith(favourite: favourite,
                                      actionType: .add) { [weak self] error in
            guard let self else { return }
            guard let error = error else {
                DispatchQueue.main.async {
                    self.presentGFAlert(title: "Success!",
                                        message: "You have successfully favourited this user 🎉",
                                        buttonTitle: "Hooray!")
                }
                return
            }
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Something went wrong",
                                    message: error.rawValue,
                                    buttonTitle: "Ok")
            }
        }
    }
}

//MARK: - UICollectionViewDelegate

extension FollowerListViewController: UICollectionViewDelegate {
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCollectionViewCell.self, forCellWithReuseIdentifier: FollowerCollectionViewCell.reuseIdentifier)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView) { collectionView, indexPath, follower in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCollectionViewCell.reuseIdentifier, for: indexPath) as? FollowerCollectionViewCell
            cell?.set(follower: follower)
            return cell
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - scrollHeight {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(userName: userName, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        
        let destinationVC = UserInfoViewController()
        destinationVC.userName = follower.login
        destinationVC.delegate = self
        let navVC = UINavigationController(rootViewController: destinationVC)
        present(navVC, animated: true)
    }
}

//MARK: - UISearchResultsUpdating, UISearchBarDelegate

extension FollowerListViewController: UISearchResultsUpdating {
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a userName"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredFollowers.removeAll()
            updateData(on: followers)
            isSearching = false
            return
        }
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: followers)
    }
}

//MARK: - UserInfoViewControllerDelegate

extension FollowerListViewController: UserInfoViewControllerDelegate {
    
    func didRequestFollowers(for userName: String) {
        //Get followers for that user
        self.userName = userName
        title = userName
        followers.removeAll()
        filteredFollowers.removeAll()
        page = 1
        collectionView.setContentOffset(.zero, animated: true)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                    at: .top,
                                    animated: true)
        getFollowers(userName: userName, page: page)
    }
    
}

//MARK: - Actions

extension FollowerListViewController {
    
    @objc func addButtonTapped() {
        showLoadingView()
        
        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: userName)
                addUserToFavourites(user: user)
                dismissLaoadingView()
            } catch {
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Bad Request",
                                   message: gfError.rawValue,
                                   buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
                dismissLaoadingView()
            }
        }
    }
}
