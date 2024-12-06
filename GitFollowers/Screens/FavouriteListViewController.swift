
import UIKit

class FavouriteListViewController: GFDataLoadingViewController {
    
    //MARK: - Properties
    
    let tableView = UITableView()
    var favourites: [Follower] = []
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavourites()
    }
    
    //MARK: - Configure UI
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favourites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(FavouritesTableViewCell.self, forCellReuseIdentifier: FavouritesTableViewCell.reuseIdentifier)
    }
    
    //MARK: - API Calls
    
    func getFavourites() {
        PersistenceManager.retriveFavourites { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let favourites):
                self.updateUI(with: favourites)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentGFAlert(title: "Something went wrong",
                                        message: error.rawValue,
                                        buttonTitle: "Ok")
                }
                
            }
        }
    }
    
    //MARK: - Updates
    
    func updateUI(with favourites: [Follower]) {
        if favourites.isEmpty {
            showEmptyStateView(with: "No favourites?\nAdd followers to your favourites list",
                               in: self.view)
        } else {
            self.favourites = favourites
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension FavouriteListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavouritesTableViewCell.reuseIdentifier) as! FavouritesTableViewCell
        let favourite = favourites[indexPath.row]
        cell.set(favourite: favourite)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favourite = favourites[indexPath.row]
        let destinationVC = FollowerListViewController(userName: favourite.login)
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        PersistenceManager.updateWith(favourite: favourites[indexPath.row],
                                      actionType: .remove) { [weak self]
            error in
            guard let self else { return }
            guard let error = error else {
                self.favourites.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
                if self.favourites.isEmpty {
                    self.showEmptyStateView(with: "No favourites?\nAdd followers to your favourites list",
                                            in: self.view)
                }
                return
            }
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Unable to remove",
                                    message: error.rawValue,
                                    buttonTitle: "Ok")
            }
        }
    }
}
