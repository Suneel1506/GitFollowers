
import UIKit

protocol UserInfoViewControllerDelegate: AnyObject {
    func didRequestFollowers(for userName: String)
}

class UserInfoViewController: GFDataLoadingViewController {
    
    //MARK: - Properties
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    
    let dateLabel = GFBodyLabel(textAlignment: .center)
    
    var itemViews: [UIView] = []
    
    var userName: String!
    
    weak var delegate: UserInfoViewControllerDelegate?
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureScrollView()
        layoutUI()
        getUserInfo()
    }
    
    //MARK: - Configure UI
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 610)
        ])
    }
    
    func layoutUI() {
        
        itemViews = [headerView, itemViewOne, itemViewTwo, dateLabel]
        
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        
        for itemView in itemViews {
            contentView.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    func configureUIElements(with user: User) {
        self.add(childVC: GFRepoItemVC(user: user, delegate: self), to: self.itemViewOne)
        self.add(childVC: GFFollowerItemVC(user: user, delegate: self), to: self.itemViewTwo)
        self.add(childVC: GFUserInfoHeaderViewController(user: user), to: self.headerView)
        self.dateLabel.text = "GitHub since \(user.createdAt.convertToMonthYearFormat())"
    }
}

//MARK: - API Calls
extension UserInfoViewController {
    
    func getUserInfo() {
        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: userName)
                configureUIElements(with: user)
            } catch {
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Bad Request",
                                   message: gfError.rawValue,
                                   buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
            }
        }
    }
}

//MARK: - Actions
extension UserInfoViewController {
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}

//MARK: - GFRepoItemVCDelegate

extension UserInfoViewController: GFRepoItemVCDelegate {
    
    func didTapGitHubProfile(for user: User) {
        //show safari VC
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlert(title: "Invalid URL",
                           message: "The url attached to the user is invalid",
                           buttonTitle: "Ok")
            return
        }
        presentSafariVC(with: url)
    }
}

//MARK: - GFFollowerItemVCDelegate

extension UserInfoViewController: GFFollowerItemVCDelegate {
    
    func didTapGetFollowers(for user: User) {
        //tell follower list screen the new user
        guard user.followers != 0 else {
            presentGFAlert(title: "No Followers",
                           message: "This user has no followers",
                           buttonTitle: "So Sad")
            return
        }
        delegate?.didRequestFollowers(for: user.login)
        dismissVC()
    }
}
