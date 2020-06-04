import UIKit
import DcCore
import SDWebImage


class GalleryCell: UICollectionViewCell {
    static let reuseIdentifier = "gallery_cell"

    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }

    func update(msg: DcMsg) {
        guard let viewtype = msg.viewtype, let fileUrl = msg.fileURL else {
            return
        }

        switch viewtype {
        case .image:
            imageView.image = msg.image
        case .video:
            imageView.image = DcUtils.generateThumbnailFromVideo(url: fileUrl)
        case .gif:
            imageView.sd_setImage(with: fileUrl, placeholderImage: nil)
        default:
            safe_fatalError("unsupported viewtype - viewtype \(viewtype) not supported.")
            break
        }
    }

    override var isSelected: Bool {
        willSet {
            // to provide visual feedback on select events
            contentView.backgroundColor = newValue ? DcColors.primary : .white
            imageView.alpha = newValue ? 0.75 : 1.0
        }
    }
}