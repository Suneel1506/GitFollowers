
import UIKit

class FavouritesTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "FavouritesTableViewCell"
    
    let avatarImageView = GFAvatarImagView(frame: .zero)
    let userNameLabel = GFTitleLabel(textAlignment: .left,
                                     fontSize: 26)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubViews(avatarImageView, userNameLabel)
        
        accessoryType = .disclosureIndicator
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            
            userNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            userNameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func set(favourite: Follower) {
        userNameLabel.text = favourite.login
        avatarImageView.downloadImage(fromURL: favourite.avatarUrl)
    }
}
